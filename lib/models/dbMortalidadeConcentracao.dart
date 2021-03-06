import 'dart:async';
import 'dart:io';
import 'package:cl50app/models/mortalidadesConcentracao.dart';

import 'concentracaoTeste.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbMortalidadeConcentracao{

  static DbMortalidadeConcentracao _dataBaseHelper;
  static Database _dataBase;

  //definir colunas padronizadas 
  String tab = 'mortalidadeConcentracao'; // NOME DA TABELA
  String colId = 'id'; //NOME COLUNA
  String colIdConcentracao = 'idConcentracao'; //NOME COLUNA
  String colMortalidade = 'mortalidade';
  String colDuracao = 'duracao';

  // Construtor
  DbMortalidadeConcentracao._createInstance();

  factory DbMortalidadeConcentracao(){

    if (_dataBaseHelper == null){
      _dataBaseHelper = DbMortalidadeConcentracao._createInstance();
    }
    return _dataBaseHelper;
  }

  Future<Database> get database async{
    if(_dataBase == null){
      _dataBase = await initializeDatabase();
    }
    return _dataBase;
  }

  Future<Database> initializeDatabase() async{
    Directory directory = await getApplicationDocumentsDirectory(); // PEGA O DIRETORIO PADRÃO FORNECIDO PELO PACOTE path_provider
    String path = directory.path + 'mortalidadeConcentracao.db';

    var dadosTesteDatabase = await openDatabase(path, version: 1, onCreate: _createDb); // CRIA O BANCO NO DIRETORIO INFORMADO
    return dadosTesteDatabase;
  }

  void _createDb(Database db, int newVersion) async{
    await db.execute('CREATE TABLE $tab('
      '$colId INTEGER PRIMARY KEY AUTOINCREMENT,' 
      '$colIdConcentracao INTEGER,'
      '$colMortalidade INTEGER,'
      '$colDuracao TEXT'
      ')');
  }

  //INCLUIR DADOS NO BANCO
  Future<int> insert(MortalidadeConcentracao dados) async{
    Database db = await this.database;
    var result = await db.insert(tab, dados.toMap());
    return result;
  }

  //Função de select por ID
  Future<MortalidadeConcentracao> getById(int id) async{
    Database db  = await this.database;

    List<Map> maps = await db.query(tab, 
    columns: [colId, colIdConcentracao, colMortalidade, colDuracao],
    where: "$colId = ?",
    whereArgs: [id]);

    if(maps.length > 0){
      return MortalidadeConcentracao.fromMap(maps.first);
    }else{
      return null;
    }
  }

  //Função de Update
  Future<int> update(MortalidadeConcentracao dados) async{
    Database db = await this.database;

    var result = await db.update(tab, dados.toMap(),
    where: '$colId = ?',
    whereArgs: [dados.id]);

    return result;
  }

  //Deletar um objeto Contato do Banco de Dados
  Future<int> delete(int id) async{
    Database db = await this.database;

    var result = await db.delete(tab,
    where: "$colId = ?",
    whereArgs: [id]);

    return result;
  }

  //Deletar varios
  Future deleteByConcentracao(int idConcentracao) async{
    Database db = await this.database;
    int op;
    List<MortalidadeConcentracao> _dados;

    await getByConcentracao(idConcentracao).then((lista){
        _dados = lista;
    });

    for(op = 0; op < _dados.length; op++){
      delete(_dados[op].id);
    }
  }

  //Obtem o numero de linhas dentro da tabela
  Future<int> getCount() async{
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT(*) FROM $tab');

    var result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<MortalidadeConcentracao>> getByConcentracao(int concentracaoId) async{
    Database db = await this.database;
    var result = await db.query(tab,
    where: "$colIdConcentracao = ?",
    whereArgs: [concentracaoId]);

    List<MortalidadeConcentracao> maps = result.isNotEmpty ? result.map(
    (e) =>  MortalidadeConcentracao.fromMap(e)).toList() : [];

    return maps;
  }

  Future close() async{
    Database db = await this.database;
    db.close();
  }
}
