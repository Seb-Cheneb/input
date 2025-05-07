The Magical Input Controller

Greetings, brave mage of code! The Magical Input Controller is an enchanted script designed to summon and manage player input in Godot 4.0+. Think of it as a spellbook that listens to your keyboard keys, mouse clicks, and even arcane gamepad buttons, all without separate incantations. You can easily rebind your “spells” (input actions) at runtime to any key or button, so if your wizardly hand grows tired, feel free to switch it up! This library is fully Godot 4 compatible (we recommend using the latest stable release
github.com
) and ties into Godot’s own InputMap system so that your code reads like casting spells, not writing boilerplate
docs.godotengine.org
.
✨ Enchanted Features

    📚 Godot 4 Compatibility – Tailored for Godot 4.x (the latest stable releases
    github.com
    ). No need to wrestle with old arcana or legacy code; the incantations here were forged for the newest engine.

    🖥️ Multi-Device Input – Handles keyboard, mouse, and gamepads all in one spell
    docs.godotengine.org
    . Whether you wave a wand over your keyboard or clutch a gamepad controller, the controller code hears you clearly and consistently.

    🔄 Configurable Controls – Each action (spell) is fully rebinding-friendly. Change keys or buttons on the fly like flipping through your spellbook’s pages. The library offers methods (e.g. rebind_spell(…)) to map any spell to any key or button at runtime.

    🧩 Beginner-Friendly – Even a novice wizard can start casting. Simply define input actions in the Project Settings → Input Map (for example, add a “fireball” spell and bind it to [F]), and the Magical Input Controller will handle the rest. No sorcery (or complicated code) required!

🛠️ Installation

Follow these steps to summon the controller into your project:

    Prepare Godot: Ensure you’re using Godot 4.x. We recommend the latest stable Godot 4 release for the best experience
    github.com
    .

    Acquire the Spellbook: Clone or download this repository into your project folder. For example:

    git clone https://github.com/YourName/MagicalInputController.git

    Add to Autoload: In the Godot Editor, go to Project → Project Settings → Autoload. Add the script file (e.g. MagicalInputController.gd) as a singleton. You might name it something mystical like InputMage or SpellCaster.

    Define Your Spells: In Project Settings → Input Map, create your actions (the spells). For instance, add an action called fireball, then click “Add Key” or “Add Controller Button” to bind it. These names (“fireball”, “dash”, etc.) will be how you reference the spells in code.

    Ready the Tome: Save your project. The Magical Input Controller will now listen to all defined actions (spells) and route them through its arcane logic.

🧙‍♀️ Usage (Spellcasting Example)

Once installed, using the Magical Input Controller in your game is as easy as reciting a charm. For example, imagine you added this script as an autoload named InputMage. Here’s how you might rebind a spell to a key and check it in your game loop:

# Example (Godot 4 GDScript):

# Rebind the "fireball" spell to the F key

InputMage.rebind_spell("fireball", Key.F)

func \_process(delta): # When the "fireball" spell is cast (key pressed), shoot a fireball!
if InputMage.is_spell_cast("fireball"):
cast_fireball()

In this incantation: InputMage.rebind_spell("fireball", Key.F) conjures up the binding of the "fireball" spell to the F key. Then, every frame we check InputMage.is_spell_cast("fireball") to see if the spell was cast. Behind the scenes, the Magical Input Controller handles all the gritty InputMap details. You can use the same code regardless of whether the player presses a keyboard key, clicks the mouse, or taps a gamepad button – the controller treats them all like spells in your grimoire.

Need more guidance? The demo scene in this repository shows a basic setup. Essentially, you create actions in Godot’s Input Map, then call the controller’s methods in your scripts. It’s beginner-friendly: no hidden glyphs or secret rituals!
🎮 Supported Input Types

With these enchanted spells, you'll never worry about which device you wield
docs.godotengine.org
. From arcane keypresses to mystical clicks and runes on a controller, our system hears them all like incantations. No device is left out of the spell. Specifically, the Magical Input Controller recognizes:

    Keyboard — Every key is a potential rune. Use QWERTY letters, numbers, function keys, or any special key as part of your spells.

    Mouse — Your enchanted pointer! Detect left-clicks, right-clicks, mouse movement or scroll wheel as triggers for your magic.

    Gamepad (Controller) — Joysticks and gamepads are fully embraced. All buttons and axes on controllers can fire spells. (Godot supports hundreds of controller models out of the box
    docs.godotengine.org
    , so almost any gamepad will work magically well.)

If a new device type arises (say, a VR wand or mystic touch screen), you can easily extend the system to listen to those inputs too. For now, the core triumph is that keyboard, mouse, and gamepad are treated as first-class magical objects.
🧙‍♂️ Contributing to the Spellbook

Have a bright new spell or an improvement potion? Contributions are most welcome! Feel free to open issues for bugs or feature requests (for example, better controller support, custom key prompts, or more whimsical examples). If you write a helpful incantation (code) or polish an existing one, fork the repo and send a Pull Request. Together we can grow this spellbook of an input system into something even more legendary. 📖✨
🦄 Magical License

All sorcery in this repository is shared under a merry MIT License (Massive Incantation Transfer) – feel free to use, modify, and distribute, as long as you keep the spells open. See the LICENSE file for full details. May your projects be enchanted and bug-free!
