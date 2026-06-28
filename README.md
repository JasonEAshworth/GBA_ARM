# GBA_ARM

University coursework: Game Boy Advance programming in ARM7TDMI assembly (with some C),
building from register basics up to a playable game.

## Labs

- **Lab01:** ARM assembly fundamentals, registers, arithmetic, and control flow
- **Lab02:** Mode 3 (bitmap) display setup and drawing pixels directly to VRAM
- **Lab03:** reading the GBA keypad register to handle button input
- **Lab04:** timers and DMA for efficient data transfers
- **Lab05:** a complete space shooter written in C, ship movement, firing, patrolling
  enemies, collision detection, and an explosion animation
- **Lab06:** an OpenCL GPU blur filter (a separate compute exercise, not GBA)

## Build and run

Assemble with `arm-elf-as -mcpu=arm7tdmi`, convert with `arm-elf-objcopy`, then run the
resulting `.bin` in the VisualBoyAdvance emulator. The root `VBA.bat` prompts for a file and
builds/launches it (see `Setup.txt`).

## License

My original assembly and C lab code is [MIT licensed](LICENSE). The bundled
**VisualBoyAdvance** emulator (in `VBA/`) is third-party software under its own (GPL) license,
and the sprite assets were course-provided and remain their owners' property.
