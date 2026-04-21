class StoryPageModel {
  final String title;
  final String text;
  final String? image;
  final String? rive;
  final String? lottie;
  final String? audio;

  const StoryPageModel({
    required this.title,
    required this.text,
    this.image,
    this.rive,
    this.lottie,
    this.audio,
  });

  factory StoryPageModel.fromJson(Map<String, dynamic> json) {
    return StoryPageModel(
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      image: json['image'],
      rive: json['rive'] ?? json['riv'],
      lottie: json['lottie'],
      audio: json['audio'],
    );
  }
}
