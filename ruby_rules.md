# Ruby Code Quality Guidelines

This document outlines key principles and practices for writing high-quality Ruby code, organized by category and complexity.

## Code Smells

These items can be identified in any Ruby file. They are often the most straightforward to resolve. At the very least, these items may prompt you to consult with an item further down in the list.

- **Use named args to remove order dependencies**
- **Hide all instance variables behind methods**
- **Isolate new instances of objects behind methods**
- **If an object must send messages to any object other than self, isolate sending that message in one single method**
- **Obey the Law of Demeter**

## Code Organization

These items are harder to identify in code alone, but looking for them will help you find opportunities to improve the structure of your program holistically.

- **Use the private keyword to create intentionally designed public interfaces**
- **Use simple dependency injection by passing collaborating objects as arguments to methods**
- **Use duck typing when you see: case statements that switch on class, or methods that ask `is_a?` or `kind_of?`**
- **Use inheritance when you are conditionally sending messages to self based on some attribute of self**
- **Promote code up to superclasses rather than down to subclasses**

## Abstraction Considerations

These items are concerned with the way in which your code models the problem domain at hand. They are more subjective, but remain useful even in quick code reviews.

- **Every class should have a one sentence description, no conjunctions allowed**
- **If you rephrase your class methods as questions to the object, each question should make sense; it should be related to the purpose of the class**
- **Messages should ask for "what" instead of dictating "how"**
- **Enforce good dependency direction**
- **Depend on abstractions before depending on concrete classes**
- **Default to composition over inheritance**
- **Create shallow hierarchies**

---

## Detailed Examples

### Use Named Args to Remove Order Dependencies

Knowing the required ordering of method arguments is a type of dependency, and it's an easy dependency to avoid.

```ruby
# Bad
def deal_cards(cards, player)
    player.update!(cards: cards)
end
```

```ruby
# Good
def deal_cards(cards:, player:)
    player.update!(cards: cards)
end
```

In the first example, if you pass the arguments in the incorrect order, bad or unexpected things might happen, and it could be unclear why. More importantly - if the argument order changes (or you add more, etc.), changing the code where you use the old version gets messy.

In the second example, you can change the ordering of the arguments any way you like, and it will work. You get the added nicety that Ruby will tell you precisely what arguments you're missing, should you forget to pass them.

### Hide All Instance Variables Behind Methods

When a class accesses an instance variable directly, that's a dependency. If the instance variable has to change, you have to change many lines of code.

Ruby provides an excellent solution for this, `attr_accessor`, and its siblings: `attr_reader`, and `attr_writer`.

```ruby
# Bad
class BettingRound
    def initialize
        @bets = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    end

    def pot
        @bets.sum
    end

    def high_bet
        @bets.max
    end
end
```

```ruby
# Good
class BettingRound
    attr_reader :bets

    def initialize
        @bets = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    end

    def pot
        bets.sum
    end

    def high_bet
        bets.max
    end
end
```

It's a subtle change, but by wrapping the `@bets` instance variable in an accessor, we get the option to override the method should we wish to, like so:

```ruby
def bets
    @bets.map { |bet| bet.to_f }
end
```

The idea here is that now `bets` is a message to which `BettingRound` responds, rather than being a piece of data `BettingRound` knows about and manipulates.

### Isolate New Instances of Objects Behind Methods

When an object knows the name of another object, that's a dependency we can avoid. When an object also knows the names of methods on a different object, that's an additional dependency.

Still, objects need to collaborate with other objects. Sometimes you can't avoid it, like if a `Game` needs to know about a `BettingRound`. Instantiating a new instance of `BettingRound` has to happen somewhere. You may choose to do so inside the `Game` class. Regardless of the best possible decision, if you have existing code where this happens, you can provide some good abstraction by wrapping instantiation in method calls.

```ruby
# Bad
class Game
    attr_accessor :current_betting_round

    def start_new_hand
        current_betting_round = BettingRound.new
    end
end
```

```ruby
# Good
class Game
    attr_accessor :current_betting_round

    def create_new_betting_round
        current_betting_round = BettingRound.new
    end

    def start_new_hand
        create_new_betting_round
    end
end
```

If the constructor signature changes for `BettingRound`, now `Game` only needs to make a change in one place. Or if we change out to a different object from `BettingRound` entirely, we only need to change it once. When an instance of `Game` wants a betting round, it just asks itself to `create_new_betting_round`, and we hand wave the details of precisely how that gets done.

### If an Object Must Send Messages to Any Object Other Than Self, Isolate Sending That Message in One Single Method

As an extension of the previous point, any time an object sends a message to another object, other than self, consider wrapping that behind a method.

```ruby
# Bad
class Game
    attr_accessor :current_betting_round

    def create_new_betting_round
        current_betting_round = BettingRound.new
    end

    def start_new_hand
        create_new_betting_round
    end

    def pot_odds
        current_betting_round.pot / current_betting_round.high_bet
    end
end
```

```ruby
# Good
class Game
    attr_accessor :current_betting_round

    def create_new_betting_round
        current_betting_round = BettingRound.new
    end

    def pot
        current_betting_round.pot
    end

    def high_bet
        current_betting_round.high_bet
    end

    def start_new_hand
        create_new_betting_round
    end

    def pot_odds
        pot / high_bet
    end
end
```

Here, we turn `pot` and `high_bet` into messages to which `Game` will respond, even though they represent messages sent to the `current_betting_round`. `Game` can still collaborate with `BettingRound`, but those collaboration points are isolated, which protects us from dependency problems.

### Obey the Law of Demeter

The Law of Demeter instructs us that objects should really only talk to themselves, or, in limited capacity, to their direct collaborators. They should not send messages to objects that collaborate with their collaborating objects.

```ruby
# Bad
class Game
    attr_accessor :players

    def initialize(players:)
        @players = players
    end

    def player_ranks
        players.map { |player| player.performance_history.rank }
    end
end

class Player
    attr_accessor :performance_history

    def initialize(performance_history:)
        @performance_history = performance_history
    end
end

class PerformanceHistory
    def rank
        # Maybe some database queries for determining rank
    end
end
```

```ruby
# Good
class Game
    attr_accessor :players

    def initialize(players:)
        @players = players
    end

    def player_ranks
        players.map { |player| player.rank }
    end
end

class Player
    attr_accessor :performance_history

    def initialize(performance_history:)
        @performance_history = performance_history
    end

    def rank
        performance_history.rank
    end
end

class PerformanceHistory
    def rank
        # Maybe some database queries for determining rank
    end
end
```

Here, in the bad example, the `Game` object violates the Law of Demeter by reaching beyond its direct collaborator, an instance of `Player`, and asking the player's `PerformanceHistory` to provide some ranking.

By allowing `Player` to respond to the request for `rank`, if we ever change the implementation of those rankings, we only have to change it in `PerformanceHistory`, and adapt to it in `Player` (notice the message to its collaborator is isolated in a method). `Game` never needs to know the change has happened.

### Use the Private Keyword to Create Intentionally Designed Public Interfaces

One of the easiest things you can do to improve your overall design is communicate your public interfaces clearly. Ruby provides the `private` keyword to aid you in this pursuit. Any methods defined after `private` can only be called by an instance of that class. This simple delineation in your class definition tells other developers (including yourself-from-the-future) that the following methods are internal only, and should not be used or depended upon elsewhere in the codebase.

```ruby
# Bad
class Dealer
    attr_reader :deck

    def initialize
        # Assume we set the deck to some full set of playing cards
        deck = [card1..card52]
    end

    def next_card
        deck.pop
    end

    def shuffle_deck
        # Shuffle deck with Fisher-Yates
        (0..deck.size - 1).each do |i|
            j = rand(deck.size - 1)
            tempi = deck[i]
            tempj = deck[j]
            deck[i] = tempj
            deck[j] = tempi
        end
    end
end
```

```ruby
# Good
class Dealer
    attr_reader :deck

    def initialize
        # Assume we set the deck to some full set of playing cards
        deck = [card1..card52]
    end

    def next_card
        deck.pop
    end

    private

    def shuffle_deck
        # Shuffle deck with Fisher-Yates
        # https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
        (0..deck.size - 1).each do |i|
            j = rand(deck.size - 1)
            tempi = deck[i]
            tempj = deck[j]
            deck[i] = tempj
            deck[j] = tempi
        end
    end
end
```

Here, the `Dealer` object is responsible for maintaining the deck, shuffling the deck, and providing the `next_card`. However, we don't want to allow other objects to instruct a `Dealer` to shuffle the deck. The `Dealer` should be fully in charge of when it shuffles the deck. By defining `shuffle_deck` after `private`, we make this intention clear, and we set up some language-level restrictions on which objects can send the `shuffle_deck` method to a `Dealer`.

Moreover, we communicate to other developers not to rely on the logic in `shuffle_deck` elsewhere. Today we shuffle using Fisher-Yates. Tomorrow we may choose some new method of doing so. Regardless of those implementation details, a `Dealer`'s public interface should always respond to `next_card`. That's much less likely to change, and other developers can rest easy asking `Dealer` objects for the `next_card` long into the future.

### Use Dependency Injection by Passing Collaborating Objects as Arguments to Methods

The term "dependency injection" is a loaded one. I'll be honest - I've avoided reading about it whenever it comes up. Sandi Metz makes the concept approachable. I hope to do the same. Here's what dependency injection means to me.

If a `Game` object needs to collaborate with a `Dealer` object, the `Game` object shouldn't directly instantiate the `Dealer`. Rather, we should pass some object to the `Game` object that represents the `Dealer` object.

```ruby
# Bad
class Game
    attr_reader :dealer, :players

    def create_dealer
        @dealer = Dealer.new
    end

    def deal_hole_cards
        create_dealer
        players.each do |p|
            first_card = dealer.next_card
            second_card = dealer.next_card
            p.update!(hole_cards: [first_card, second_card])
        end
    end
end
```

```ruby
# Good
class Game
    def deal_hole_cards(dealer:, players:)
        players.each do |p|
            first_card = dealer.next_card
            second_card = dealer.next_card
            p.update!(hole_cards: [first_card, second_card])
        end
    end
end
```

In the bad example, we follow an earlier directive by wrapping an object instantiation inside a method. That's good. But then we set that instance as an instance variable, and access it directly from the `deal_hole_cards` method. However, this approach leaves us with a dependency. `Game` needs to know about the dealer object it stored in the instance variable. It also needs to know about the players it stores as an instance variable.

In the good example, we design `Game` to expect some dealer and players arguments to its `deal_hole_cards` method. Now we can call that method and provide any objects that respond to `next_card` (for the dealer argument) and `update!` (for the players). It provides us with flexibility, and we inject those object dependencies into the `Game` class.

### Use Duck Typing When You See: Case Statements That Switch on Class, or Methods That Ask `is_a?` or `kind_of?`

Duck typing is useful for designing different classes that respond to the same message in order to treat them similarly. "Duck" comes from the saying "if it looks like a duck, walks like a duck, and quacks like a duck", with the implication being "it's a duck".

Sometimes you want similar classes to respond to a message slightly differently based on what they are. Say you have a `TexasHoldEm` class, which deals two cards to each player for their hole cards, and a `FiveCardDraw` class, which deals five cards. Here are two ways you could implement that:

```ruby
# Bad
class Table
    attr_accessor :game

    def begin_hand
        if game.kind_of?(TexasHoldEm)
            game.deal_two_hole_cards
        elsif game.kind_of(FiveCardDraw)
            game.deal_five_hole_cards
        end
    end
end
```

```ruby
# Good
class Table
    attr_accessor :game

    def begin_hand
        game.deal_hole_cards
    end
end
```

Here we replaced two different, but similar, methods with one duck type. In the bad example, we ask the game object to `deal_two_hole_cards` if it's a `TexasHoldEm` object, or to `deal_five_hole_cards` if it's a `FiveCardDraw` object. We can make that cleaner by defining one method on each class, with the same name: `deal_hole_cards`, and deal the appropriate number of cards in each class-specific implementation.

### Use Inheritance When You Are Conditionally Sending Messages to Self Based on Some Attribute of Self

Duck typing is a good way to improve your design when you already have multiple objects that respond to similar messages. But sometimes you end up with a class that could benefit from inheritance. One sign your design might be in need of inheritance is when messages are being conditionally sent based on some internal attribute.

```ruby
# Bad
class Game
    attr_reader :dealer, :game_type, :players

    def deal_hole_cards
        if game_type == 'texas_hold_em'
            number_of_cards = 2
        elsif game_type == 'five_card_draw'
            number_of_cards = 5
        end
        players.each do |player|
            cards = dealer.deal_cards(number_of_cards)
            player.update!(hole_cards: cards)
        end
    end
end
```

```ruby
# Good
class Game
    attr_reader :dealer, :players
end

class TexasHoldEm < Game
    def deal_hole_cards
        players.each do |player|
            cards = dealer.deal_cards(2)
            player.update!(hole_cards: cards)
        end
    end
end

class FiveCardDraw < Game
    def deal_hole_cards
        players.each do |player|
            cards = dealer.deal_cards(5)
            player.update!(hole_cards: cards)
        end
    end
end
```

Here, we start with a `Game` class that could benefit from some refactoring. It conditionally deals a different number of cards based on whether or not its `game_type` is `texas_hold_em` or `five_card_draw`. By creating a `TexasHoldEm` class and a `FiveCardDraw` class, we can implement their respective `deal_hole_cards` methods appropriately for each type of game, and track one less instance variable in the `Game` superclass.

### Promote Code Up to Superclasses Rather Than Down to Subclasses

In the previous example, I hand-waved the restructuring of the classes. If you're going through the process of creating inheritance in your project where there was none to begin, keep in mind it is much easier to identify shared functions from subclasses and move them up, rather than figure out what might be different for subclasses by looking at the parent class.

All that to say, if you're creating inheritance, build out one new empty abstract class and move up what you need instead of adapting an existing class to be the superclass.

### Every Class Should Have a One Sentence Description, No Conjunctions Allowed

The first of the SOLID design principles is the single-responsibility principle. Volumes have been written about this principle alone. For these object-oriented heuristics, here's what you should ask yourself while reviewing your code:

> **"Can I describe what this class does in one sentence, without using any conjunctions?"**

If the answer is no, your class could likely benefit from being split up into separate objects. It is probably responsible for too many things.

### If You Rephrase Your Class Methods as Questions to the Object, Each Question Should Make Sense

Once you feel confident your class can be described with a single sentence, you can take the single-responsibility principle one step further by inspecting each method and rephrasing the method as a question to that class. Say it out loud and ask yourself: **"does it make sense for me to ask this specific question of this specific object, given its purpose?"**

If the answer is no, you should consider moving this method to a different class. Or perhaps your class could still benefit from being separated into different objects.

### Messages Should Ask for "What" Instead of Dictating "How"

The prior exercise, rephrasing methods into questions, sets us up for this next item: methods should represent messages sent to the object. The object should receive the method call, and then answer the question.

In order for your object to determine the response, it should have freedom to do so however it likes. Method calls should not dictate the internal behavior of the object. They should work as interfaces for other objects to retrieve relevant information. Keep in mind the distinction between public and private methods. An object's public methods should represent a set of questions it will respond to. Its private methods are an appropriate place to store implementation details, which are more likely to change than the kinds of questions the object will be asked.

### Enforce Good Dependency Direction

In earlier heuristics, we've looked at how to eliminate dependencies, or manage them responsibly. In any non-trivial software, it's impossible to eliminate all dependencies. Objects must collaborate and rely on one another. When you identify these necessary dependencies (and put safeguards around them), you will need to decide which object depends on which. This is the direction of your dependencies.

Generally speaking, objects should not depend on other objects that are likely to change more than themselves. When you use a framework like Rails, you can remain somewhat assured that framework APIs will change less frequently than your code. It's responsible for your models to inherit from `ActiveRecord`.

Evaluate your own objects and determine which seem most stable. Have other objects depend on them, and so forth.

### Depend on Abstractions Before Depending on Concrete Classes

For a more practical application of good dependency direction, consider the difference between abstract classes and concrete classes. In the `Game` inheritance example, we had `TexasHoldEm` and `FiveCardDraw` depend on `Game`, rather than one another. If you are having trouble identifying which classes are most stable and best to depend on, look for the superclasses in your inheritance hierarchy to guide you.

### Default to Composition Over Inheritance

Duck typing and other methods of composition are easier to maintain and reason about than inheritance. When you are refactoring your code and splitting up objects into smaller pieces, you should strive to create small, composable objects, rather than an overly-nested inheritance tree.

### Create Shallow Hierarchies

When you do find that inheritance is the right choice for your design, do your best to keep your inheritance hierarchy shallow. As a general guideline, it's good to stop at one or two levels of inheritance. Any deeper should be an indication to you that you may have missed some opportunity for composition somewhere along the line.
