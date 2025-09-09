# ConvertFrom-Base64

Reverts a base64 string into text

## Syntax

```powershell
ConvertFrom-Base64 -Base64String <string> [-Encoding <System.Text.Encoding>]
```

## Description

This cmdlet takes a base64 encoded string input and converts it back into a regular string. It can also accept an optional encoding parameter to specify the character encoding to use for the conversion. By default, it uses UTF-8 encoding.

## Examples

### Example 1

```powershell
ConvertFrom-Base64 -Base64String 'Q2h1Y2hpY2jDpHNjaHRsaQ=='
```
```
Chuchichäschtli
```

### Example 2

```powershell
'QwBoAHUAYwBoAGkAYwBoAOQAcwBjAGgAdABsAGkA' | ConvertFrom-Base64 -Encoding ([System.Text.Encoding]::Unicode)
```
```
Chuchichäschtli
```

## Parameters

### -Base64String

- **Description**: The input base64 string to be converted back to text.
- **Type**: `string`
- **Required**: Yes

### -Encoding

- **Description**: The character encoding to use for the conversion.
- **Type**: `System.Text.Encoding`
- **Required**: No
- **Default**: UTF-8
