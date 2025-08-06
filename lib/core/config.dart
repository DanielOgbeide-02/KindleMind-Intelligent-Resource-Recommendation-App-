class Config {
  static const bool useRemoteAPI = true; // Change this to false for local API
  // static const bool useLocalAPI = true; // Change this to true for remote API


  //tends to change
  static const String localApiUrl = "http://192.168.100.61:5000";

  static const String remoteApiUrl = "https://kindle-mind.onrender.com";

  static String get apiUrl => useRemoteAPI ? remoteApiUrl : localApiUrl;
}
