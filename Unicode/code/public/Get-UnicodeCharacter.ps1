function Get-UnicodeCharacter
{
    [CmdletBinding(DefaultParameterSetName = "string")]
    param (
        [parameter(HelpMessage = "item")]
        $InputItem,
        [String]$Search,
        [parameter(HelpMessage = "When input is literal. will take string and int at face value")]
        [switch]$Literal,
        [parameter(HelpMessage = "List details of item")]
        [switch]$Details
    )
    
    begin
    {
        $dataloc = $Script:locations.Values | % { gci $_ -Filter "*.txt" } | ? { $_.basename -match "[0-9]{4}-[0-9]{2}-[0-9]{2}" } | sort name | select -first 1
        if ($script:UnicodeList.count -eq 0)
        {
            Write-debug "Loading unicode list from $dataloc"
            $script:UnicodeList = Import-Csv -Delimiter ';' -Path $dataloc -Header Code, Name, Category, CombineClass, BidiClass, Deomp, Number, Mirrored, OldName, Comment, UpperCase, LowerCase, TitleCase
            # Update-TypeData -MemberType "UnicodeChar" -MemberName "Byte"
        }
    }
    process
    {
        $ProcessList = @()
        Write-Debug "Input is $($inputitem.gettype()), Literal is $($Literal.IsPresent)"
        if ($inputitem -is [byte])
        {
            $ProcessList += [System.Convert]::ToInt64($InputItem)
            #  $inputitem
        }
        elseif ($inputitem -is [String])
        {
            if ($inputitem.tolower() -match "0x[a-f0-9]{2,5}" -and !$Literal)
            {
                Write-debug "Processing 0x string reference"
                $convert = [scriptblock]::create($inputitem).invoke()
                Write-debug "$inputitem = $convert; $($convert.gettype()); $($convert|ConvertTo-Json -Compress)"
                $ProcessList += [System.Convert]::ToInt64($convert)
            }
            elseif ($inputitem.tolower() -match "[uU]+[a-f0-9]{2,5}" -and !$Literal)
            {
                Write-debug "Processing u+ string reference"
                $convert = $InputItem.tolower().replace("u+","0x")
                $ProcessList += [System.Convert]::ToInt64($([scriptblock]::create($convert).invoke()))
            }
            else 
            {
                $i = 0
                $ProcessList += [System.Text.ASCIIEncoding]::Unicode.GetBytes($inputitem) | Where-Object { $i % 2 -eq 0; $i++ }
            }
        }
        elseif ($inputitem -is [int] -or $inputitem -is [long])
        {
            if ($Literal)
            {
                $ProcessList +=  "$InputItem".split("")| Where-Object { $i % 2 -eq 0; $i++ }
            }
            else
            {
                $ProcessList += $inputitem
            }
        }
        else {
            throw "Could not parse input of type $($inputitem.gettype())"
        }

        # $ProcessList
        $ProcessList.foreach{
            $Code = ('{0:x}' -f $_).PadLeft(4,"0")
            # Write-host "$_ = $code"
            $out = $script:UnicodeList.where{ $_.code -eq $Code }
            if ($details)
            {
                Write-Output $out
            }
            else
            {
                Write-Output $out | Select-Object code, name, category, UpperCase
            }
        }
        <#
        Name	M	N	(1) When a string value not enclosed in <angle brackets> occurs in this field, it specifies the character's Name property value, which matches exactly the name published in the code charts. The Name property value for most ideographic characters and for Hangul syllables is derived instead by various rules. See Section 4.8, Name in [Unicode] for a full specification of those rules. Strings enclosed in <angle brackets> in this field either provide label information used in the name derivation rules, or—in the case of characters which have a null string as their Name property value, such as control characters—provide other information about their code point type.
        General_Category	E	N	(2) This is a useful breakdown into various character types which can be used as a default categorization in implementations. For the property values, see General Category Values.
        Canonical_Combining_Class	N	N	(3) The classes used for the Canonical Ordering Algorithm in the Unicode Standard. This property could be considered either an enumerated property or a numeric property: the principal use of the property is in terms of the numeric values. For the property value names associated with different numeric values, see DerivedCombiningClass.txt and Canonical Combining Class Values.
        Bidi_Class	E	N	(4) These are the categories required by the Unicode Bidirectional Algorithm. For the property values, see Bidirectional Class Values. For more information, see Unicode Standard Annex #9, "Unicode Bidirectional Algorithm" [UAX9].
        The default property values depend on the code point, and are explained in DerivedBidiClass.txt

        Decomposition_Type
        Decomposition_Mapping	E, S	N	(5) This field contains both values, with the type in angle brackets. The decomposition mappings exactly match the decomposition mappings published with the character names in the Unicode Standard. For more information, see Character Decomposition Mappings.
        Numeric_Type
        Numeric_Value	E, N	N	(6) If the character has the property value Numeric_Type=Decimal, then the Numeric_Value of that digit is represented with an integer value (limited to the range 0..9) in fields 6, 7, and 8. Characters with the property value Numeric_Type=Decimal are restricted to digits which can be used in a decimal radix positional numeral system and which are encoded in the standard in a contiguous ascending range 0..9. See the discussion of decimal digits in Chapter 4, Character Properties in [Unicode].
        E, N	N	(7) If the character has the property value Numeric_Type=Digit, then the Numeric_Value of that digit is represented with an integer value (limited to the range 0..9) in fields 7 and 8, and field 6 is null. This covers digits that need special handling, such as the compatibility superscript digits.
        Starting with Unicode 6.3.0, no newly encoded numeric characters will be given Numeric_Type=Digit, nor will existing characters with Numeric_Type=Numeric be changed to Numeric_Type=Digit. The distinction between those two types is not considered useful.

        E, N	N	(8) If the character has the property value Numeric_Type=Numeric, then the Numeric_Value of that character is represented with a positive or negative integer or rational number in this field, and fields 6 and 7 are null. This includes fractions such as, for example, "1/5" for U+2155 VULGAR FRACTION ONE FIFTH.
        Some characters have these properties based on values from the Unihan data files. See Numeric_Type, Han.

        Bidi_Mirrored	B	N	(9) If the character is a "mirrored" character in bidirectional text, this field has the value "Y"; otherwise "N". See Section 4.7, Bidi Mirrored of [Unicode]. Do not confuse this with the Bidi_Mirroring_Glyph property.
        Unicode_1_Name (Obsolete as of 6.2.0)	M	I	(10) Old name as published in Unicode 1.0 or ISO 6429 names for control functions. This field is empty unless it is significantly different from the current name for the character. No longer used in code chart production. See Name_Alias.
        ISO_Comment (Obsolete as of 5.2.0; Deprecated and Stabilized as of 6.0.0)	M	I	(11) ISO 10646 comment field. It was used for notes that appeared in parentheses in the 10646 names list, or contained an asterisk to mark an Annex P note.
        As of Unicode 5.2.0, this field no longer contains any non-null values.

        Simple_Uppercase_Mapping	S	N	(12) Simple uppercase mapping (single character result). If a character is part of an alphabet with case distinctions, and has a simple uppercase equivalent, then the uppercase equivalent is in this field. The simple mappings have a single character result, where the full mappings may have multi-character results. For more information, see Case and Case Mapping.
        Simple_Lowercase_Mapping	S	N	(13) Simple lowercase mapping (single character result).
        Simple_Titlecase_Mapping	S	N	(14) Simple titlecase mapping (single character result).
        Note: If this field is null, then the Simple_Titlecase_Mapping is the same as the Simple_Uppercase_Mapping for this character.
        
        #>
    }
    
    end
    {
        
    }
}