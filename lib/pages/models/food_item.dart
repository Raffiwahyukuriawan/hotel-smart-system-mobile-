class FoodItem {
  final int id;
  final String name;
  final String price;
  final String image;
  final String category;
  int quantity;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.quantity = 1,
  });
}
