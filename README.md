# lita-debug

[![Build Status](https://travis-ci.org/spajus/lita-debug.png?branch=master)](https://travis-ci.org/spajus/lita-debug?branc=master)
[![Coverage Status](https://coveralls.io/repos/github/spajus/lita-debug/badge.svg?branch=master)](https://coveralls.io/github/spajus/lita-debug?branch=master)

A plugin for debugging [Lita](https://www.lita.io) interactively, in
production.

## Installation

Add lita-debug to your Lita instance's Gemfile:

``` ruby
gem "lita-debug"
```

## Configuration

```ruby
# lita_config.rb

Lita.configure do |config|
  config.handlers.debug.enable_eval = true
  config.handlers.debug.restrict_eval_to = [:admins]
  config.handlers.debug.restrict_debug_to = [:admins, :developers]
end
```

## Usage

```
Lita > lita debug
---
:server:
  :hostname: minion.local
:room: !ruby/object:Lita::Room
  id: shell
  metadata: {}
  name: shell
:user: !ruby/object:Lita::User
  id: '1'
  metadata:
    name: Shell User
  name: Shell User

Lita > lita eval response.room.name
"shell"
Lita > lita eval robot.name
"Lita"
Lita > lita eval 1+2
3
```
