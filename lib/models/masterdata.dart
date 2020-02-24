class Material_data {
  var material;
  String name;
  String color;
  String talla;
  String bar_code;
  String depto;
  String mvgr1;
  String cantidad;
  @override
  toString() {
    return this.material +
        this.name +
        this.color +
        this.talla +
        this.bar_code +
        this.depto +
        this.mvgr1 +
        this.cantidad;
  }

  Material_data(
      {this.material,
      this.name,
      this.color,
      this.talla,
      this.bar_code,
      this.depto,
      this.mvgr1,
      this.cantidad});

  //To insert the data in the bd, we need to convert it into a Map
  //Para insertar los datos en la bd, necesitamos convertirlo en un Map
  Map<String, dynamic> toMap() => {
        "material": material,
        "name": name,
        "color": color,
        "talla": talla,
        "bar_code": bar_code,
        "depto": depto,
        "mvgr1": mvgr1,
        "cantidad": cantidad,
      };

  //to receive the data we need to pass it from Map to json
  //para recibir los datos necesitamos pasarlo de Map a json
  //factory Material_data.fromMap(Map<String, dynamic> json) => new Material_data(
  factory Material_data.fromMap(dynamic json) => new Material_data(
        material: json["material"],
        name: json["name"],
        color: json["color"],
        talla: json["talla"],
        bar_code: json["bar_code"],
        depto: json["depto"],
        mvgr1: json["mvgr1"],
        cantidad: json["cantidad"],
      );
}

final List<String> Material_model = [
  'material',
  'name',
  'color',
  'talla',
  'bar_code',
  'depto',
  'mvgr1',
  'cantidad',
];

final List<Zona_Field>  ZonasCount =[];

final List<String> Zona_Fild_Model = [
  'zona',
  'material',
  'bar_code',
  'canti_count',
  'date' ,
];

class Zona_Field {
  var zona;
  String material;
  String bar_code;
  String name;
  int canti_count;
  String date ;
  @override
  toString() {
    return this.zona + this.bar_code + this.canti_count;
  }

  Zona_Field(
      {this.zona, this.material, this.bar_code, this.name, this.canti_count, this.date});

  //To insert the data in the bd, we need to convert it into a Map
  //Para insertar los datos en la bd, necesitamos convertirlo en un Map
  Map<String, dynamic> toMap() => {
        "zona": zona,
        "material": material,
        "bar_code": bar_code,
        "name": name,
        "canti_count": canti_count,
        "date": date,
      };

  //to receive the data we need to pass it from Map to json
  //para recibir los datos necesitamos pasarlo de Map a json
  //factory Material_data.fromMap(Map<String, dynamic> json) => new Material_data(
  factory Zona_Field.fromMap(dynamic json) => new Zona_Field(
        zona: json["zona"],
        material: json["material"],
        bar_code: json["bar_code"],
        name: json["name"],
        canti_count: json["canti_count"],
        date: json["date"],
      );

}
