import 'package:json_schema2/json_schema.dart';

final configurationSchema = JsonSchema.create({
  r"$schema": "http://json-schema.org/draft-04/schema#",
  "type": "array",
  "items": [
    {
      "type": "object",
      "properties": {
        "id": {"type": "string"},
        "jsonAccessor": {"type": "string"},
        "name": {"type": "string"},
        "url": {"type": "string"},
        "imageType": {"type": "integer"},
        "headers": {"type": "object"},
        "logoSource": {"type": "string"}
      },
      "required": [
        "id",
        "jsonAccessor",
        "name",
        "url",
        "imageType",
        "headers",
        "logoSource"
      ]
    }
  ]
});
