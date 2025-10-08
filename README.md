# Koni Cam - Raspberry Pi 5 based IMX219 camera module Video Recording Device

This repository documents the setup and usage of `rpicam-apps`, a suite of camera applications for *usually* Raspberry Pi OS, but this case for me is I'm using it on a Raspberry Pi 5 running Ubuntu 24.04.3. The setup includes configuring the camera module (e.g., IMX219) and building `libcamera` and `rpicam-apps` from source for video recording capabilities, such as 1080p@30fps desktop top-down videos for soldering, 3D printing timelapses, and assembly projects.

## Prerequisites

- **Hardware**: Raspberry Pi 5 with a compatible camera module (e.g., IMX219).
- **OS**: Ubuntu 24.04.3 LTS or higher installed on the Raspberry Pi 5. *I have not tested it on other ubuntu version*
- **Storage**: At least 4GB free space for builds and dependencies. Probably more depending on your case.

## What :
Raspberry Pi 5 has a 2 CSI/DSI hybrid slots for either a monitor or a camera module.
I temporarily yoinked one IMX219 camera module from my robotics team.
I'll include and show the datasheet and documents about most of those hardwares. 
But to be honest, you don't really need to go down the rabbit hole of what or wyh is CSI camera module.

## Why :

Well I want to make use of this IMX219 camera module since my robotics team Automech has decided not to use the CSI camera module because the setting up step and usage is too inconvenient for our robot's implementation case.

Plus I want to record a timelapse video of Bambu A1 3D printer printing those random stuff I have designed, and also just to learn about building and using a non-standard binaries out of the source.

## How

Entry of the *Rabbit Hole* that is using IMX219 camera module on Ubuntu OS within Rasbperry Pi 5 computer is really deep and shallow at the same time.

I'll introduce a CSI camera driver programs setting up/building from source helper script in the files. But I can't guarantee that your specific case will be exactly same as mine.
As I said, using IMX219 or ore broadly using CSI camera module with Ubuntu OS (well at least version 24.04) requires you to be *bit* more hands on.

Normally CSI camera would run with little to no effort in the normal Raspberry Pi OS. 

CSI cameras require you to use rpicam-apps programs to be able to actually see and record with yours. Well, as it unsurprisingly turns out, you can **NOT** use it on Ubuntu OS out of the box.

* If you want a quick and dirty work of building the rpicam-apps tools follow this [link](https://askubuntu.com/questions/1542652/getting-rpicam-tools-rpicam-apps-working-on-ubuntu-22-04-lts-for-the-raspber)

* If you want to exactly learn and know how and why exactly is it, you can read [deeper](#getting-your-hands-and-brain-dirty)

## Getting your hands and brain dirty
hmmmm, why does rpicam-apps is not at ubuntu apt in the first place? Is it going to supported in Ubuntu 25>? 
Why does Raspberry Pi OS apt has it? Is there like a hardware or OS "blocking" or some sort of in-compatibility? Well I'll have to dive into this hole a little bit more...
