/// Playful micro-copy strings for Lost & Tossed
class AppStrings {
  // App
  static const String appTagline = 'Every object tells a story';
  
  // Categories with personality
  static const Map<String, String> categoryDescriptions = {
    'lost': 'Unintentionally left behind',
    'tossed': 'Deliberately discarded', 
    'posted': 'Intended for display',
    'marked': 'Non-removable markings',
    'curious': 'Anything else odd or unclassifiable',
  };
  
  static const Map<String, String> categoryEmojis = {
    'lost': '🧤',
    'tossed': '🗑️',
    'posted': '📋',
    'marked': '🎨',
    'curious': '🤔',
  };
  
  // Playful item descriptions
  static const List<String> lostItemMicroCopy = [
    'A glove begins its solo adventure.',
    'Someone\'s keys are having their own journey.',
    'This toy is looking for its human.',
    'A list waiting to be reunited with its writer.',
    'A phone case exploring the world alone.',
  ];
  
  static const List<String> tossedItemMicroCopy = [
    'The snack that left only a clue.',
    'A wrapper\'s final destination.',
    'Someone\'s coffee cup chose this spot to rest.',
    'Evidence of a meal well enjoyed.',
    'A can that found its temporary home.',
  ];
  
  static const List<String> postedItemMicroCopy = [
    'Poster\'s still here, but the event is long gone.',
    'A message trying to reach someone.',
    'This flyer has stories to tell.',
    'Community announcements finding their audience.',
    'Someone\'s art brightening up the neighborhood.',
  ];
  
  static const List<String> markedItemMicroCopy = [
    'Street art that speaks without words.',
    'Someone left their mark on the world.',
    'A creative expression fixed in time.',
    'Art that chose this canvas.',
    'A message etched for all to see.',
  ];
  
  static const List<String> curiousItemMicroCopy = [
    'Something that defies easy categorization.',
    'An object with its own mysterious purpose.',
    'The universe\'s way of keeping things interesting.',
    'A delightful puzzle waiting to be solved.',
    'Proof that the world is full of surprises.',
  ];
  
  // User actions
  static const String capturePrompt = 'What did you find today?';
  static const String sharePrompt = 'Share your discovery with the community';
  static const String explorePrompt = 'Discover what others have found';
  
  // Location
  static const String nearbyTitle = 'Discoveries Near You';
  static const String noLocationMessage = 'Unable to determine your location. You can still browse and contribute!';
  static const String locationPermissionDenied = 'Location access helps you discover nearby items and share your finds with the community.';
  
  // Community
  static const String communityMapTitle = 'Community Discovery Map';
  static const String contributorBadge = 'Fellow Explorer';
  static const String noItemsYet = 'No discoveries here yet. Be the first to document something interesting!';
  
  // Onboarding
  static const String welcomeTitle = 'Welcome to Lost & Tossed!';
  static const String welcomeSubtitle = 'Help build a playful map of our shared spaces by documenting the objects you encounter.';
  static const String onboardingStep1 = 'Find something interesting in public spaces';
  static const String onboardingStep2 = 'Take a photo and add some context';
  static const String onboardingStep3 = 'Share it with the community';
  
  // Error messages (friendly)
  static const String networkError = 'Having trouble connecting. Check your internet and try again.';
  static const String imageUploadError = 'Couldn\'t upload that photo. Give it another try?';
  static const String locationError = 'Having trouble finding your location. You can still add items manually!';
  static const String genericError = 'Something unexpected happened. Please try again.';
  
  // Success messages
  static const String itemSharedSuccess = 'Your discovery has been shared with the community!';
  static const String profileUpdatedSuccess = 'Profile updated successfully!';
  static const String commentAddedSuccess = 'Comment added!';
}
