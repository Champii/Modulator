Nodulator-View
================

View system for [Nodulator](https://github.com/Champii/Nodulator)

## Exemples

#### Simple incrementing button
```livescript
App = N.View {foo: 0}, ->
  button do
    click: ~> @foo++
    @foo

N.Render App
```

#### Node manipulation

Get and change dom dynamicaly

```livescript
App = N.View {name: 'ChangeMe'}, ->
  div do
    i = input type: \text
    button do
      click: ~> @name = i.GetElement!value
      @name

N.Render App
```


#### Compenent based and reusability

```livescript
FooView = N.View -> "Foo: #{@bar}"
BarView = N.View -> "Bar: #{@foo}"

Foo = N \foo FooView
Bar = N \bar BarView

Component = N.View (Resource, obj) ->
  div do
    button do
      click: -> Resource.Create obj
      \Create Resource._type
    Resource.List!

App = N.View ->
  div do
    Component Foo, bar: 42
    Component Bar, foo: 42

N.Render App

```

#### TodoList (client only)

```livescript
Item = N.View (item) ->
  li do
    "#{item.value}: #{item.done}"
    button do
      click: -> item.done = !item.done
      \Change

List = N.View {list: []}, ->
  div do
    i = input type: \text
    button do
      click: ~> @list = @list ++ [{value: i.GetElement!value, done: false}]
      \Add
    ul do
      @list |> map Item

N.Render List
```

#### TodoList (client/server)

```livescript
TaskView = N.View ->
  div do
    "#{@id}: #{@value} #{if @done => '(Done)' else  ''}"
    button do
      click: ~> @Set done: !@done
      if @done => \Undone else \Dones
    button do
      click: ~> @Delete!
      \Delete

Task = N \Task TaskView, schema: \strict
  ..Field \value \string
  ..Field \done \bool .Default false

App = N.View ->
  div do
    i = input type: \text
    button do
      click: ~>
        if (elem = i.GetElement!).value.length
          Task
            .Create elem{value}
            .Then -> elem.value = ''
      \Create
    Task.List!

N.Render App
```
