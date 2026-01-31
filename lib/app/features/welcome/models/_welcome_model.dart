class WelcomeModel{
  final String title;
  final String description;
  final String imagePath;

  WelcomeModel({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

final List<WelcomeModel> welcomeData = [
  WelcomeModel(
    title: 'Your Digital Sanctuary',
    description: "Welcome to Your Digital Sanctuary. Tired of scattered passwords and online worries? We're here to guard your digital life with an unbreakable shield. Everything you store is encrypted, private, and always under your control. Step in, breathe easy.",
    imagePath: 'assets/svgs/otp-security.svg',
  ),
  WelcomeModel(
    title: 'Say Goodbye to Password Headaches',
    description: 'Say Goodbye to Password Headaches. Unlock a simpler online life where forgotten passwords are a thing of the past. Your logins are organized, instantly accessible, and always just a tap away. Get ready for seamless access, everywhere.',
    imagePath: 'assets/svgs/idea.svg',
  ),
  WelcomeModel(
    title: 'Your Digital Life, Synced & Secure',
    description: "Your Digital Life, Synced & Secure. Step into the future of effortless security. With smart sync across all your devices, and advanced protection working silently in the background, you're always connected, always safe, always in control.",
    imagePath: 'assets/svgs/mobile.svg',
  ),
];