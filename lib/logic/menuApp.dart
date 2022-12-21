import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gocomics/main.dart';
import 'package:http/http.dart' as http;

class menuApp extends StatefulWidget {
  const menuApp({Key? key}) : super(key: key);

  @override
  State<menuApp> createState() => _menuAppState();
}

class _menuAppState extends State<menuApp> {
  int _pestAct = 0;
  List<Widget> _paginas = [
    PaginaComics(),
    PaginaBuscar(),
    PaginaUser()
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Material App Bar"),
          backgroundColor: Colors.black,
        ),
        body: _paginas[_pestAct],
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index){
            setState(() {
              _pestAct = index;
            });
          },
          backgroundColor: Colors.black,
          unselectedItemColor: Colors.white,
          selectedItemColor: Color(0xFFF44336),
          currentIndex: _pestAct,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.book, color: Color(0xFFF44336),), label: "Comics",),
            BottomNavigationBarItem(icon: Icon(Icons.search, color: Color(0xFFF44336),), label: "Buscar",),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded, color: Color(0xFFF44336),), label: "Cuenta")
          ],
        ),
      ),
    );
  }
}

class PaginaComics extends StatefulWidget {
  PaginaComics({Key? key}) : super(key: key);

  @override
  State<PaginaComics> createState() => _PaginaComicsState();
}

class _PaginaComicsState extends State<PaginaComics> {
  List _comics = [];
  final listaComics = ScrollController();
  static bool hasMore = true;
  int limit = 0;


  SiguiendoComics()async {
    final response = await http.post(Uri.parse("http://192.168.1.68:80/developer/siguiendo.php"), body:
    {
      "idusuario": "1",
      "limite": limit.toString(),
    });

    if(response.statusCode == 200) {
      setState(() {
        _comics = json.decode(response.body);
      });
      return _comics;
    } else {
      throw Exception("No sigues ningún comic.");
    }
  }

  LeidoComics(String idcomic)async {
    final response = await http.post(Uri.parse("http://192.168.1.68:80/developer/leido.php"), body:
    {
      "idusuario": "1",
      "idcomic": idcomic,
    });

    if(response.statusCode == 200) {
      limit = 0;
      SiguiendoComics();
    } else {
      throw Exception("No hay conexión.");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SiguiendoComics();
    listaComics.addListener(() {
      if(listaComics.position.maxScrollExtent == listaComics.offset) {
        fetch();
      }
    });
  }

  Future fetch() async {
    limit=limit+10;
    final response = await http.post(Uri.parse("http://192.168.1.68:80/developer/siguiendo.php"), body:
    {
      "idusuario": "1",
      "limite": limit.toString(),
    });
    if(response.statusCode == 200) {
      final List newItems = json.decode(response.body);
      if(newItems.length<limit) {
        hasMore = false;
      }
      setState(() {
        _comics.addAll(newItems);
      });
    } else {
      throw Exception("No hay conexión.");
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          controller: listaComics,
          itemCount: _comics == null ? 0 : _comics.length+1,
          itemBuilder: (BuildContext context, int index) {
            if (index < _comics.length) {
              return ListTile(
                title: Text(_comics[index]["nombre_coleccion"] + " #" + _comics[index]["numero"]),
                subtitle: Text(_comics[index]["ano_comienzo"]),
                leading: Image(
                  width: 50,
                  height: 100,
                  image: NetworkImage(_comics[index]["imagencom"].toString().length == 0? "https://go-comic.000webhostapp.com/Comics3.0/assets/img/"+_comics[index]["imagencom"] : "https://go-comic.000webhostapp.com/Comics3.0/assets/img/"+_comics[index]["imagencol"] ),
                ),
                trailing: FloatingActionButton(
                  onPressed: (){
                    LeidoComics(_comics[index]["id_comic"]);
                  },
                  child: Icon(Icons.check_circle_outline, color: Colors.white,),
                  backgroundColor: const Color(0xFFF44336),
                  splashColor: Colors.white,
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: hasMore == true ? CircularProgressIndicator() : Text("No hay más."),
                ),
              );
            }
          }),
    );
  }
}

class PaginaBuscar extends StatelessWidget {
  const PaginaBuscar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Buscar", style: TextStyle(fontSize: 25),),
    );
  }
}

class PaginaUser extends StatelessWidget {
  const PaginaUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
        icon: const Icon(Icons.logout),

      ),
    );
  }
}

