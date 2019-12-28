# Modular_Storage
Modular storage is mod for Factorio that adds a storage system that can store and show a lot of resources. and can be imported and exported in multiple ways

Modular storage
=============
This is a mod for Factorio that allows you to build a big stockpile to store your items.
Items can be pumped in with input belts and can be taken out by output belts.
A interface chest is also available, which can be set as an input or an output chest.

Thread: https://forums.factorio.com/viewtopic.php?f=97&t=49616
This mod is in early stage and bugs may occure, please report them ;)

Guide
-------------
It is preffered to create a big stockpile from the tiles first, and later add the controller, since this will scan the stockpile for its connected blocks.
When adding/removing a tile after a stockpile is placed, the whole stockpile will be rechecked for connected tiles, which can be a issue for performance.

You can add an inventory pannel to know what is actually stored inside the stockpile and use that in the circuit network.

To set the output items:
Hover over a belt while holding the item you want to output and press ALT + Q to set lane 1 and ALT + E to set lane 2
The lanes can be cleared by pressing the keybind with an emty cursor

To set the interfaces:
By default the interface will work as an input. To set output items, hover over it while holding the item you want to set and press ALT + W, this will add one stack of that item to the interface when availeble.
Pressing ALT + W multiple times will add that item again until all slots will have an item set.
Pressing the keybind with an emty cusor will remove the last item that is set from the interface filter. Note: it will not remove it from the interface itself.

Note keybinds for A/Q and Z/W are swapped by default by factorio when using an AZERTY keyboard.