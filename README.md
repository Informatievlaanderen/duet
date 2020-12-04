# duet
Base repository for the publication environment for data standards for the DUET project

#### Autoescaping is enabled
For all templates, the given variables (the values of the jsonld) will be autoescaped. This means any characters that might be interpreted (e.g. '<', '>', ...) will be replaced with a neutral string and displayed as such. Autoescaping is currently deactivated for the usage values and can be for any variable if the safe filter is added. Doing so requires all entered values to be html safe and might cause errors if they are not.
```
{{ entity.usage[language] | safe }}
```