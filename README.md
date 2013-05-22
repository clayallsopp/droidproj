# DroidProj - Automating Android Management

Managing Android projects sucks. Static XML sucks. Do it all in Ruby, with a `Droidfile` and a DSL:

```ruby
# ./Droidfile

res do
  drawable 'back_icon' do
    state(enabled: false) do
        hdpi './images/back_disabled@hdpi.png'
        ldpi './images/back_disabled@ldpi.png'
        mdpi './images/back_disabled.png'
    end
    hdpi './images/back@hdpi.png'
    ldpi './images/back@ldpi.png'
    mdpi './images/back.png'
  end
end
```

This will (non-destructively) create the following directory structure in your Android project:

```
.
|-- res
|---- drawable
|------ back_icon.xml
|---- drawable-ldpi
|------ back_icon.png
|------ back_icon_enabled_false.png
|---- drawable-hdpi
|------ back_icon.png
|------ back_icon_enabled_false.png
|---- drawable-mdpi
|------ back_icon.png
|------ back_icon_enabled_false.png
```

## Installation

`gem install droidproj`

This will install the `droid` CLI, which you can use in any directory with a `Droidfile`:

```bash
$ ls -l
...
AndroidManifest.xml
images
src
target
Droidfile

$ droid
Evaluating Droidfile...
Creating filesystem...
Creating ./res...
...
Copying ./images/back.png to ./res/drawable-mdpi/back_icon.png...
Done!

$ ls -l
...
AndroidManifest.xml
images
res
...
```

## Usage

```ruby
# ./Droidfile
# This is all plain-old *Ruby*, like a Gemfile or Rakefile

# Declare that you're writing to the `res` folder
res do
  # Create a new drawable XML with name `back_icon.xml`
  # (this is what you'll access in code as R.drawable.back_icon)
  drawable 'back_icon' do
    # Assign new images using [hdpi, ldpi, mdpi, or xhdpi]
    xhdpi './images/back@xhdpi.png'
    hdpi './images/back@hdpi.png'
    ldpi './images/back@ldpi.png'
    mdpi './images/back.png'

    # Assign new images for different states with `state`
    # (these are translated to the `android:state_[enabled/focused/etc]` XML)
    state(focused: true) do
        hdpi './images/back_focused@hdpi.png'
        ldpi './images/back_focused@ldpi.png'
        mdpi './images/back_focused.png'
    end
    state(enabled: false) do
        hdpi './images/back_disabled@hdpi.png'
        ldpi './images/back_disabled@ldpi.png'
        mdpi './images/back_disabled.png'
    end

  end
end
```

## Contact

Clay Allsopp ([http://clayallsopp.com](http://clayallsopp.com))

- [http://twitter.com/clayallsopp](http://twitter.com/clayallsopp)
- [clay@usepropeller.com](clay@usepropeller.com)

## License

DroidProj is available under the MIT license. See the LICENSE file for more info.
