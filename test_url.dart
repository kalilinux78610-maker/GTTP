void main() {
  String? url = 'user-avatars/01KVD1Z67XKXE3QV7SFZT3DQGM.png';
  print('Raw: $url');
  
  final storageAwarePath = url.startsWith('storage/') ? url : 'storage/$url';
  
  // Simulated origin
  final origin = 'https://gttp.efsouls.com';
  final base = origin.endsWith('/') ? origin.substring(0, origin.length - 1) : origin;
  final segment = storageAwarePath.startsWith('/') ? storageAwarePath.substring(1) : storageAwarePath;
  
  print('Resolved: $base/$segment');
}
