import 'dart:convert';
import 'dart:io';

import 'package:efood_multivendor_restaurant/data/api/api_client.dart';
import 'package:efood_multivendor_restaurant/data/model/response/product_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/profile_model.dart';
import 'package:efood_multivendor_restaurant/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class RestaurantRepo {
  final ApiClient apiClient;
  RestaurantRepo({@required this.apiClient});

  Future<Response> getProductList(String offset) async {
    return await apiClient.getData('${AppConstants.PRODUCT_LIST_URI}?offset=$offset&limit=10');
  }

  Future<Response> getAttributeList() async {
    return apiClient.getData(AppConstants.ATTRIBUTE_URI);
  }

  Future<Response> getCategoryList() async {
    return await apiClient.getData(AppConstants.CATEGORY_URI);
  }

  Future<Response> getSubCategoryList(int parentID) async {
    return await apiClient.getData('${AppConstants.SUB_CATEGORY_URI}$parentID');
  }

  Future<Response> updateRestaurant(Restaurant restaurant, XFile logo, XFile cover, String token) async {
    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse('${AppConstants.BASE_URL}${AppConstants.RESTAURANT_UPDATE_URI}'));
    request.headers.addAll(<String,String>{'Authorization': 'Bearer $token'});
    if(GetPlatform.isMobile && logo != null) {
      File _file = File(logo.path);
      request.files.add(http.MultipartFile('logo', _file.readAsBytes().asStream(), _file.lengthSync(), filename: _file.path.split('/').last));
    }
    if(GetPlatform.isMobile && cover != null) {
      File _file = File(cover.path);
      request.files.add(http.MultipartFile('cover_photo', _file.readAsBytes().asStream(), _file.lengthSync(), filename: _file.path.split('/').last));
    }
    Map<String, String> _fields = Map();
    _fields.addAll(<String, String>{
      '_method': 'put', 'name': restaurant.name, 'contact_number': restaurant.phone, 'schedule_order': restaurant.scheduleOrder ? '1' : '0',
      'opening_time': restaurant.availableTimeStarts, 'closeing_time': restaurant.availableTimeEnds, 'off_day': restaurant.offDay,
      'address': restaurant.address, 'minimum_order': restaurant.minimumOrder.toString(), 'delivery': restaurant.delivery ? '1' : '0',
      'take_away': restaurant.takeAway ? '1' : '0', 'gst_status': restaurant.gstStatus ? '1' : '0', 'gst': restaurant.gstCode,
      'delivery_charge': restaurant.deliveryCharge.toString()
    });
    request.fields.addAll(_fields);
    print(request.fields);
    http.StreamedResponse response = await request.send();
    return Response(statusCode: response.statusCode, statusText: response.reasonPhrase);
  }

  Future<Response> addProduct(Product product, XFile image, Map<String, String> attributes, String token, bool isAdd) async {
    http.MultipartRequest request = http.MultipartRequest(
        'POST', Uri.parse('${AppConstants.BASE_URL}${isAdd ? AppConstants.ADD_PRODUCT_URI : AppConstants.UPDATE_PRODUCT_URI}',
    ));
    request.headers.addAll(<String,String>{'Authorization': 'Bearer $token'});
    if(GetPlatform.isMobile && image != null) {
      File _file = File(image.path);
      request.files.add(http.MultipartFile('image', _file.readAsBytes().asStream(), _file.lengthSync(), filename: _file.path.split('/').last));
    }
    Map<String, String> _fields = Map();
    List<String> _addonIds = [];
    product.addOns.forEach((addon) {
      _addonIds.add(addon.id.toString());
    });
    _fields.addAll(<String, String>{
      'name': product.name, 'price': product.price.toString(), 'discount': product.discount.toString(),
      'discount_type': product.discountType, 'category_id': product.categoryIds[0].id,
      'addon_ids': jsonEncode(_addonIds), 'available_time_starts': product.availableTimeStarts,
      'available_time_ends': product.availableTimeEnds, 'description': product.description,
    });
    if(product.categoryIds.length > 1) {
      _fields.addAll(<String, String> {'sub_category_id': product.categoryIds[1].id});
    }
    if(!isAdd) {
      _fields.addAll(<String, String> {'_method': 'put', 'id': product.id.toString()});
    }
    if(attributes.length > 0) {
      _fields.addAll(attributes);
    }
    request.fields.addAll(_fields);
    print('=====> ${request.url.path}\n'+request.fields.toString());
    http.StreamedResponse response = await request.send();
    return Response(statusCode: response.statusCode, statusText: response.reasonPhrase);
  }

  Future<Response> deleteProduct(int productID) async {
    return await apiClient.deleteData('${AppConstants.DELETE_PRODUCT_URI}?id=$productID');
  }

  Future<Response> getRestaurantReviewList(int restaurantID) async {
    return await apiClient.getData('${AppConstants.RESTAURANT_REVIEW_URI}?restaurant_id=$restaurantID');
  }

  Future<Response> getProductReviewList(int productID) async {
    return await apiClient.getData('${AppConstants.PRODUCT_REVIEW_URI}/$productID');
  }

  Future<Response> updateProductStatus(int productID, int status) async {
    return await apiClient.getData('${AppConstants.UPDATE_PRODUCT_STATUS_URI}?id=$productID&status=$status');
  }

}