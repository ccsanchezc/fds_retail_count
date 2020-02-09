class Zonasdb{
  int id;
  String name;
  String phone;

  Zonasdb ({this.id, this.name, this.phone});

  //To insert the data in the bd, we need to convert it into a Map
  //Para insertar los datos en la bd, necesitamos convertirlo en un Map
  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "phone": phone,
  };

  //to receive the data we need to pass it from Map to json
  //para recibir los datos necesitamos pasarlo de Map a json
  factory Zonasdb.fromMap(Map<String, dynamic> json) => new Zonasdb(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
  );
}