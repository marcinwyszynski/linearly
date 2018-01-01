# Linearly: linear workflow framework for Ruby

[![Gem Version](https://badge.fury.io/rb/linearly.svg)](https://badge.fury.io/rb/linearly) [![codecov](https://codecov.io/gh/marcinwyszynski/linearly/branch/master/graph/badge.svg)](https://codecov.io/gh/marcinwyszynski/linearly) [![Codefresh build status](https://g.codefresh.io/api/badges/build?repoOwner=marcinwyszynski&repoName=linearly&branch=master&pipelineName=test&accountName=marcinwyszynski&type=cf-1)](https://g.codefresh.io/repositories/marcinwyszynski/linearly/builds?filter=trigger:build;branch:master;service:59271ac5fc38af00018ddfea~test)

_"Nothing is particularly hard if you divide it into small jobs"_

**- Henry Ford**

## TL;DR

It's like [`interactor`](https://github.com/collectiveidea/interactor), [`solid_use_case`](https://github.com/gilbert/solid_use_case), or [`codequest_pipes`](https://github.com/codequest-eu/codequest_pipes). But subtly different.

Linearly is a microframework for building complex workflows out of small, reusable, and composable parts. We call each such part a `Step`, and their sequence - a `Flow`. `Step`s are effectively functions which take a [`State`](http://www.rubydoc.info/gems/statefully/Statefully/State) and return a `State`. Each `Step` is expected to represent a discrete part of your business logic, with explicitly defined `inputs` (always) and `outputs` (if applicable).

`State` can either be a [`Success`](http://www.rubydoc.info/gems/statefully/Statefully/State/Success), a [`Failure`](http://www.rubydoc.info/gems/statefully/Statefully/State/Failure) or it can be [`Finished`](http://www.rubydoc.info/gems/statefully/Statefully/State/Finished). The difference between `Failure` and `Finished` states is like between an exception and a guard clause (early return). `Linearly` uses the `statefully` gem for state management, so be sure to visit [its docs](https://github.com/marcinwyszynski/statefully) for more details. Inside a `Flow`, each individual `Step` will only be executed if passed a `Success` state, otherwise the flow is terminated early. It's both a simple and powerful concept.

## Example

Code speaks louder than words, so let's see how Linearly could help you strucure an actual workflow. It comes from a Rails API for a React/Redux SPA, from a controller resposible for exchanging an [OAuth](https://oauth.net/2/) code for a [JWT token](https://jwt.io/), simplified for clarity.

### Controller

```ruby
class SessionsController < ApplicationController
  FLOW = # See [1]
    Auth0::GetUserData
    .>> Auth0::FindOrCreateUser # See [2]
    .>> Users::EnsureActive
    .>> Users::IssueToken

  def create
    state = Statefully::State.create(**params) # See [3]
    result = FLOW.call(state).resolve # See [4]
    head :unauthorized and return if result.finished? # See [5]
    render json: {token: result.token}, status: :created # See [6]
  end
end
```

#### Controller notes

1. `FLOW` is constructed statically, and assigned to a constant. This alone allows us to eliminate an entire class of problems where you may try to create a `Flow` from things that aren't `Steps`.

1. The `>>` operator is defined as a method, which [creates a `Flow` from a `Step`](http://www.rubydoc.info/gems/linearly/Linearly%2FMixins%2FFlowBuilder.%3E%3E), or [adds a `Step` to a `Flow`](http://www.rubydoc.info/gems/linearly/Linearly/Flow#>>-instance_method). The actual `Flow` constructor [is pretty mundane](http://www.rubydoc.info/gems/linearly/Linearly%2FFlow:initialize), but you're not likely to ever use it. Note that if you want to put each `Step` on a single line (my personal preference, [heavily influenced by Elixir pipe operator](https://elixirschool.com/en/lessons/basics/pipe-operator/)), you'll need to prepend each `>>` call with a dot, to tell the parser that the new line is a part of the previous statement.

1. As already mentioned before, every `Step` needs to take an instance of `State` as input and return an instance of `State` as output. `Flow` has the same signature, so what we're doing here is creating a `State` from controller parameters. This is actually safe (unless your business logic requires some sanitization, that is), because `Flow` validates its inputs. You can find more information about validation in one of the sections below.

1. A properly implemented `Step` will rescue any exception thrown during execution, and wrap it into an instance of [`Statefully::State::Failed`](http://www.rubydoc.info/gems/statefully/Statefully/State/Failure). Calling `#resolve` on it re-raises the exception, while for any other `State` ([`Success`](http://www.rubydoc.info/gems/statefully/Statefully/State/Success) or [`Finished`](http://www.rubydoc.info/gems/statefully/Statefully/State/Finished)) it simply returns itself. Unless you need some form of error introspection, it is advised that you use `#resolve` liberally and don't explicitly raise from your `Step`s. This way unexpected application failures will cause crashes which your favorite exception tracker can notify you about.

1. Some `Flow`s may not be expected to always complete - for example, `Auth0::GetUserData` can terminate the entire flow if user data associated with the parameters passed to the controller cannot be verified with the identity provider ([Auth0](https://auth0.com/) in this case). It's not an exception per se, but it makes you want not to run subsquent steps. That's where `Statefully::State::Finished` comes in handy. Both it, and `Statefully::State::Success` will respond with `true` to the `#successful?` message (since there is no exception), but only the former will respond with `true` to `#finished?`. Since `Statefully::State::Failed` is no longer an option (we unwrapped the state with `#resolve` - see above), we can distinguish between a flow which completed, and one which was terminated early. In the latter case, we don't issue a JWT token but inform the user about their unauthorized status.

1. `Statefully::State` behaves like a read-only [`OpenStruct`](http://ruby-doc.org/stdlib-2.5.0/libdoc/ostruct/rdoc/OpenStruct.html), so all of its properties are available through reader methods. Since `Flow` validates inputs and outputs (more on that later), we can safely assume that the `token` field (actually provided by the last `Step`) will be set on the successful `State`.

### Step

Each of the steps in the flow is about 30 lines long, so you can view it whole in your text editor or IDE without having to scroll. Its tests can easily cover mutliple condition and their associated code paths. Below you will find an actual annotated `Step` - the first one used in the `Flow` described above.

```ruby
module Auth0
  class GetUserData < Linearly::Step::Static # See [1]
    def self.inputs # See [2]
      {code: String, redirect_path: String, state: String}
    end

    def self.outputs # See [3]
      {user_data: Hash}
    end

    def call # See [4]
      succeed(user_data: user_data) # See [5]
    rescue Auth0Service::NotFound
      finish # See [6]
    end

    private

    def user_data
      Auth0Service.from_env.user_data(auth0_params)
    end

    def auth0_params
      {
        code: code, # See [7]
        redirect_path: redirect_path,
        state: state.state, # See [8]
      }
    end
  end
end
```

#### Step notes

1. `Step` itself is first and foremost a concept, which we'd call an [interface](https://docs.oracle.com/javase/tutorial/java/concepts/interface.html) or a [typeclass](http://learnyouahaskell.com/types-and-typeclasses) if we used a different programming language. Still, in order to make the package easier to use, Linearly includes valid implementations you can use as your base classes. [`Linearly::Step::Static`](http://www.rubydoc.info/gems/linearly/Linearly/Step/Static) is one of them - please see the section below for more details.

1. `inputs` is one of the methods required by the `Step` 'interface'. It's supposed to be a `Hash<Symbol, Proc>`. Keys represent the names of `State` properties required by the `Step`. Values are matchers taking actual input and verifying (by returning `true` or `false`) if it matches expectations. If you don't need such a fine-grained control over your input, you can use class name for a shorthand type checking (my personal favorite), or merely `true` to ensure that the property exists but without checking its type or value (not recommended) - please see the [documentation](http://www.rubydoc.info/gems/linearly/Linearly/Validation/Expectation) for more details.

1. `outputs` is simlar to `inputs`, but in Linearly's reference implementations it is not required, since empty defaults are provided. While `inputs` are strictly required, `outputs` only make sense for `Steps` which add something to the `State` they return.

1. `call` is the only public instance method you need to implement on a subclass of [`Linearly::Step::Static`](http://www.rubydoc.info/gems/linearly/Linearly/Step/Static). Please see its own section for more details.

1. As already mentioned, `Step`s are effectively functions which take a [`State`](http://www.rubydoc.info/gems/statefully/Statefully/State) and return a `State`. Here, by calling `succeed` with `user_data` we're returning a new `State` with an extra property set, compliant with what we promised in the `outputs` section. Note that we're calling `succeed` without a receiver here - thanks to the magic of [`method_missing`](http://www.rubydoc.info/gems/linearly/Linearly%2FStep%2FStatic:method_missing), all unknown messages in a subclass of [`Linearly::Step::Static`](http://www.rubydoc.info/gems/linearly/Linearly/Step/Static) are by default passed to the input `State`.

1. `finish` is similar to `succeed` in that it returns a `State` - albeit a finished instead of a successful one. What we're doing here is transforming a well known exception (identity provider not recognizing user credentials) into an orderly early return of our `flow`.

1. As already mentioned, all unknown messages in a subclass of [`Linearly::Step::Static`](http://www.rubydoc.info/gems/linearly/Linearly/Step/Static) are by default passed to the input `State`. `State` itself also [passes all unknown messages to its underlying collection of properties](http://www.rubydoc.info/gems/statefully/Statefully%2FState:method_missing), so the `code` message is eventually correctly resolved using two levels of indirection.

1. `state` on the other hand is a valid input, but it has a naming conflict with the a private method of `Linearly::Step::Static`, giving you access to the input state. Hence, we can't use double message redirection as with `code`, and need to explicitly send this message to the input `state`.
