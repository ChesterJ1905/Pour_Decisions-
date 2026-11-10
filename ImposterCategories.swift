import Foundation

struct ImposterCategories {

    static let categories: [String: [String]] = [//hardcoded list of all catgories for games themes and subtopics

        "Animals": [
            "Dog", "Cat", "Horse", "Cow", "Pig", "Sheep", "Goat", "Chicken",
            "Lion", "Tiger", "Bear", "Elephant", "Giraffe", "Zebra", "Kangaroo", "Panda",
            "Monkey", "Wolf", "Fox", "Rabbit", "Deer", "Moose", "Camel", "Dolphin",
            "Shark", "Whale", "Octopus", "Frog", "Snake", "Owl", "Eagle", "Penguin"
        ],

        "Food": [
            "Pizza", "Burger", "Hot Dog", "Tacos", "Burrito", "Sushi", "Ramen", "Sandwich",
            "Steak", "Chicken Wings", "Fries", "Nachos", "Pancakes", "Waffles", "Donut", "Bagel",
            "Spaghetti", "Mac and Cheese", "Rice", "Salad", "Soup", "Cereal", "Toast", "Eggs",
            "Cupcake", "Brownie", "Cookie", "Pie", "Ice Cream", "Cheesecake", "Popcorn", "Pretzel"
        ],

        "Places": [
            "Beach", "Park", "Zoo", "School", "Library", "Museum", "Restaurant", "Cafe",
            "Airport", "Hotel", "Hospital", "Mall", "Stadium", "Movie Theater", "Gym", "Bakery",
            "Aquarium", "Amusement Park", "Arcade", "Bowling Alley", "Gas Station", "Supermarket", "Farm", "Campground",
            "Playground", "University", "Train Station", "Bus Stop", "Castle", "Forest", "Mountain", "Island"
        ],

        "Sports": [
            "Soccer", "Basketball", "Baseball", "Football", "Tennis", "Golf", "Hockey", "Volleyball",
            "Swimming", "Track", "Boxing", "Wrestling", "Cycling", "Bowling", "Badminton", "Rugby",
            "Lacrosse", "Gymnastics", "Karate", "Skateboarding", "Surfing", "Snowboarding", "Skiing", "Rowing",
            "Archery", "Fencing", "Table Tennis", "Weightlifting", "Diving", "Water Polo", "Cricket", "Ultimate Frisbee"
        ],

        "Movies": [
            "Superhero", "Alien", "Wizard", "Robot", "Pirate", "Detective", "Monster", "Princess",
            "Dragon", "Vampire", "Zombie", "Spy", "Ninja", "Knight", "Ghost", "King",
            "Queen", "Treasure", "Adventure", "Magic", "Dinosaur", "Space", "Heist", "Race",
            "Jungle", "Island", "Castle", "Battle", "Time Travel", "Secret Agent", "Apocalypse", "Supervillain"
        ],

        "Drinks": [
            "Water", "Milk", "Coffee", "Tea", "Soda", "Juice", "Lemonade", "Milkshake",
            "Smoothie", "Hot Chocolate", "Iced Coffee", "Root Beer", "Energy Drink", "Sports Drink", "Punch", "Slushie",
            "Boba", "Espresso", "Latte", "Mocha", "Cappuccino", "Apple Cider", "Orange Juice", "Chocolate Milk",
            "Grape Juice", "Iced Tea", "Green Tea", "Sparkling Water", "Coconut Water", "Protein Shake", "Cola", "Ginger Ale"
        ],

        "School": [
            "Math", "Science", "History", "English", "Art", "Music", "Biology", "Chemistry",
            "Physics", "Geography", "Algebra", "Drama", "Economics", "Coding", "Spanish", "French",
            "Psychology", "Statistics", "Journalism", "Engineering", "Literature", "Calculus", "Debate", "Robotics",
            "Geometry", "Astronomy", "Philosophy", "Government", "Choir", "Band", "Theater", "Photography"
        ],

        "Objects": [
            "Backpack", "Phone", "Laptop", "Tablet", "Chair", "Table", "Lamp", "Clock",
            "Bottle", "Cup", "Plate", "Fork", "Knife", "Spoon", "Pencil", "Pen",
            "Notebook", "Book", "Headphones", "Keyboard", "Mouse", "Wallet", "Camera", "Remote",
            "Speaker", "Mirror", "Blanket", "Pillow", "Flashlight", "Calculator", "Umbrella", "Suitcase"
        ]
    ]
    //functions, randomizes choice of subtopic from above lists
    static var categoryNames: [String] {
        categories.keys.sorted()
    }

    static func randomCategory() -> String {
        categoryNames.randomElement() ?? "Animals"
    }

    static func randomWord(for category: String) -> String {
        categories[category]?.randomElement() ?? "Dog"
    }
}
