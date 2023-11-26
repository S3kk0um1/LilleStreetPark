import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  final List<String> itemList;

  // Constructor to receive the list of items
  ListPage({required this.itemList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Page'),
      ),
      body: itemList.isEmpty
          ? Center(
        child: Text('The list is empty.'),
      )
          : ListView.builder(
        itemCount: itemList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(itemList[index]),
            // You can customize the ListTile based on your item structure
            // For example, you can add icons, subtitles, etc.
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ListPage(
      // Pass your list of items here
      itemList: ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'],
    ),
  ));
}
