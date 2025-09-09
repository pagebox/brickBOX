# ConvertTo-Base64

Converts a String into a base64 string

## Syntax

```powershell
ConvertTo-Base64 -TextString <string> [-Encoding <System.Text.Encoding>]
```

## Description

This cmdlet takes a string input and converts it into a base64 encoded string. It can also accept an optional encoding parameter to specify the character encoding to use for the conversion. By default, it uses UTF-8 encoding.

## Examples

### Example 1

```powershell
ConvertTo-Base64 -TextString 'Chuchichäschtli'
```
```
Q2h1Y2hpY2jDpHNjaHRsaQ==
```

### Example 2

```powershell
'Chuchichäschtli' | ConvertTo-Base64 -Encoding ([System.Text.Encoding]::Unicode)
```
```
QwBoAHUAYwBoAGkAYwBoAOQAcwBjAGgAdABsAGkA
```

## Parameters

### -TextString

- **Description**: The input string to be converted to base64.
- **Type**: `string`
- **Required**: Yes

### -Encoding

- **Description**: The character encoding to use for the conversion.
- **Type**: `System.Text.Encoding`
- **Required**: No
- **Default**: UTF-8

