describe "Get-UnicodeCharacter"{
    $testcases = @(
        @{
            param = @{
                InputItem = "B"
            }
            name = "capital B"
            return = @{
                code = "0042"
                Name = "LATIN CAPITAL LETTER B"
            }
        }
        @{
            param = @{
                InputItem = "`t"
            }
            name = "tab"
            return = @{
                code = "0009"
                Name = "<control>"
                UpperCase = "CHARACTER TABULATION"
            }
        }
        @{
            param = @{
                InputItem = "0x1f"
            }
            name = "Info character - byte reference"
            return = @{
                code = "001F"
                Name = "<control>"
                UpperCase = "INFORMATION SEPARATOR ONE"
            }
        }
        @{
            param = @{
                InputItem = 31
            }
            name = "Info character - byte int"
            return = @{
                code = "001F"
                Name = "<control>"
                UpperCase = "INFORMATION SEPARATOR ONE"
            }
        }
        @{
            param = @{
                InputItem = "hei på deg"
                Literal = $true
            }
            name = "String literal"
            # return = @{
            #     code = "001F"
            #     Name = "<control>"
            #     UpperCase = "INFORMATION SEPARATOR ONE"
            # }
        }
        @{
            param = @{
                Inputobject = 12345
                Literal = $true
            }
            name = "Int literal"
            # return = @{
            #     code = "001F"
            #     Name = "<control>"
            #     UpperCase = "INFORMATION SEPARATOR ONE"
            # }
        }
    )
    it "'<name>' does not throw" -TestCases $testcases{
        param(
            $param,
            $name,
            $return
        )
        {Get-UnicodeCharacter @param}|should -not -Throw
    }

    it "can get the correct data for '<name>'" -TestCases $testcases{
        param(
            $param,
            $name,
            $return
        )
        
        $data = Get-UnicodeCharacter @param
        $return.keys|%{
            $data.$_ |should -be $return.$_ 
        }
    }
}