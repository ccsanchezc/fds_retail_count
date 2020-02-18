class Material{
  var material;
  String name;
  String color;
  String talla;
  String bar_code;
  String depto;
  String mvgr1;
  String cantidad;

  Material ({this.material, this.name, this.color, this.talla, this.bar_code, this.depto, this.mvgr1, this.cantidad});

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
  factory Material.fromMap(Map<String, dynamic> json) => new Material(
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