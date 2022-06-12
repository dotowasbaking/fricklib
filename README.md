fricklib a ui lib made with synapse drawing library i have no idea if it works on other exploits probably not have fun
!!! this project was abandoned so theres a bunch of unfinished/janky shit in it
```
> library
    new({Title = title <string>})
        :Tab({Title = title <string>})
            :Subframe({Title = title <string>})
                :Toggle({
                    Title = title <string>,
                    Enabled = enabled <boolean[optional]>,
                    Callback = callback <function[optional]>(<boolean>),
                    Pointer = pointer <string[optional]>
                })
                    :ColorPicker({
                        Title = pickerName <string>,
                        DefaultColor = defaultColor <Color3[optional]>,
                        Callback = callback <function[optional]>(<Color3>)
                    })
                    :Keybind({
                        DefaultKeybind = defaultKeybind <EnumItem[optional]>,
                        KeybindCallback = keybindCallback <function[optional]>,
                        KeybindChangedCallback = <function[optional]>(<EnumItem>),
                        Pointer = pointer <string[optional]>
                    })
                :Slider({
                    Title = title <string>,
                    Default = defaultKeybind <float>,
                    Measurement = suffix <string[optional]>,
                    Increment = increment <float[optional]>,
                    Mex = maxValue <float[optional]>,
                    Callback = callback <function[optional]>(<float>),
                    Pointer = pointer <string[optional]>
                })
                :Button({
                    Title = title <string>,
                    ClickedText = clickedText <string[optional]>,
                    ConfirmationText = confirmationText <string[optional]>,
                    ButtonCallback = callback <function[optional]>,
                    Pointer = pointer <string[optional]>
                })
                :TextBox({
                    Title = title <string>,
                    DefaultText = defaultText <string[optional]>,
                    Callback = callback <function[optional]>(<string>),
                    Pointer = pointer <string[optional]>
                })
                :Dropdown({
                    Title = title <string>,
                    Options = dropdownOptions <dictionary>,
                    Callback = callback <function[optional]>(<dictionary>),
                    MultiSelect = allowMultiSelect <boolean[optional]>,
                    Pointer = pointer <string[optional]>
                })
                :Configindow()
    :Notify(text <string>, duration <float[optional]>)
    :SetTitle(text <string>)
    :SetKeybind(keybind <EnumItem>)
    :Hide()
    :Show()
    :Open()
    :SetIcon(pngData <string>)
    :Destroy()

```
