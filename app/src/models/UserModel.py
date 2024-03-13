class Usuario():

    def __init__(self,id,nombre,documento_identidad,numero_documento,telefono,correo,direccion,cargo):
        self.id = id
        self.nombre = nombre
        self.documento_identidad = documento_identidad
        self.numero_documento = numero_documento
        self.telefono = telefono
        self.correo = correo
        self.direccion = direccion
        self.cargo = cargo
    
    def to_json(self):
        return{
            'id' : self.id,
            'nombre' : self.nombre,
            'documento_identidad' : self.documento_identidad,
            'numero_documento' : self.numero_documento,
            'telefono' : self.telefono,
            'correo' : self.correo,
            'direccion' : self.direccion,
            'cargo' : self.cargo,
        }