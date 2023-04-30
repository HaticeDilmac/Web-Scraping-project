// ignore_for_file: unused_import, must_be_immutable, unused_local_variable

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:web_scaping_example_one/main.dart';

import 'model/book.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHome());
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  bool isLoading =
      false; //verinin çekilip çekilmediği sırada kontrol sağlanacak.

  @override
  void initState() {
    super.initState();
    getData();
  }

  //Web sitemizin ilgili sayfasının url uzantısını alırız.
  var url = Uri.parse(
      "https://www.kitapyurdu.com/index.php?route=product/category&filter_category_all=true&path=1_2&filter_in_stock=1&sort=publish_date&order=DESC&limit=50");

  Future getData() async {
    setState(() {
      isLoading = true;
    });
    var res = await http.get(url); //Bu url adresine gidip verileri getirecek.
    final body = res.body; //verilerin text kısmını almak için
    final document = html.parse(body);
    //web sitesinde hangi bölümden verileri çekeceksek o classın adını gireriz.
    var response = document
        .getElementsByClassName('product-grid')[0]
        .getElementsByClassName('product-cr')
        .forEach((e) {
      setState(() {
        kitaplar.add(Kitaplar(
            resim: e.children[2].children[0].children[0].children[0]
                .attributes['src']
                .toString(),
            kitap: e.children[3].text,
            yazar: e.children[5].text,
            fiyat: e.children[8].children[0].text,
            yayinevi: e.children[4].text));
      });
      setState(() {
        isLoading = false;
      });
    });
  }

//Kitabın resim urlleri => element.children[2].children[0].children[0].children[0].attributes['src']
//Kitabın adı => element.children[3].text
//Yayın Evi => element.children[4].text
//Yazar => element.children[5].text
//Fiyat => element.children[8].children[0].text ->
//Eğer sekizinci childrenın liste fiyatına erişmek istersek 0'ıncı elemana erişirdik.

  List<Kitaplar> kitaplar = []; //Listemiz Kitaplar modelinden oluşur.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Web Scrapping KitapYurdu',
          ),
        ),
        body: isLoading ? buildCircularProcessingBar() : buildList());
  }

  buildList() {
    return SafeArea(
        child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 0.54 //en boy oranı
          ),
      itemCount: kitaplar.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(255, 187, 133, 222)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Center(
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          index.toString(),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                  ),
                  Image.network(kitaplar[index].resim),
                  Wrap(
                    children: [
                      TextWidget(
                        text: "Kitap İsmi:",
                      ),
                      Text(
                        kitaplar[index].kitap,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Wrap(
                    children: [
                      Text(
                        kitaplar[index].yazar,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Wrap(
                    children: [
                      TextWidget(text: 'Kitap YayınEvi:'),
                      Text(
                        kitaplar[index].yayinevi,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Wrap(
                    children: [
                      Text(
                        " ${kitaplar[index].fiyat} ₺",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ));
  }

  buildCircularProcessingBar() {
    return const Center(
        child: CircularProgressIndicator(
      strokeWidth: 5,
      color: Colors.grey,
    ));
  }
}

class TextWidget extends StatelessWidget {
  TextWidget({
    required this.text,
    super.key,
  });
  String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }
}
