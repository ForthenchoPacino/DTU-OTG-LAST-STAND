import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class Utils{
  static Future cacheImage(BuildContext context,String urlImage)=>precacheImage(CachedNetworkImageProvider(urlImage), context);
}