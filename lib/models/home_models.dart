class User {
  final String name;
  final String avatar;
  final String greeting;
  final String role;

  const User({
    required this.name,
    required this.avatar,
    required this.greeting,
    required this.role,
  });
}

class SpecialOffer {
  final String id;
  final String discount;
  final String title;
  final String description;
  final String bgColor;
  final String image;

  const SpecialOffer({
    required this.id,
    required this.discount,
    required this.title,
    required this.description,
    required this.bgColor,
    required this.image,
  });
}

class Service {
  final String id;
  final String name;
  final String icon;
  final String bgColor;
  final String iconColor;

  const Service({
    required this.id,
    required this.name,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}

class PopularService {
  final String id;
  final String title;
  final String category;
  final String provider;
  final double price;
  final double rating;
  final int reviewCount;
  final String image;
  final bool isBookmarked;

  const PopularService({
    required this.id,
    required this.title,
    required this.category,
    required this.provider,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.image,
    this.isBookmarked = false,
  });
}

class Review {
  final String id;
  final String user;
  final String avatar;
  final double rating;
  final String time;
  final String content;
  final int likes;

  const Review({
    required this.id,
    required this.user,
    required this.avatar,
    required this.rating,
    required this.time,
    required this.content,
    required this.likes,
  });
}
