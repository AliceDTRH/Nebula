letters = ['A','B','C','D','E','F','G','H','I',\
           'J','K','L','M','N','O','P','Q','R',\
           'S','T','U','V','W','X','Y','Z','a','b','c','.',' ']
phonetics = ['m','b','f','θ','ð','t','d','s','z',\
           'ɾ','r','l','ʃ','dʒ','j','g','x','ɣ',\
           'ħ','ʕ','h','ʔ','i','ɛ','a','u','o','ɔ','ə','.',' ']

pholet = {phonetics[i]: letters[i] for i in range(len(letters))}

def convert(mes):
    result = ""
    for counter, char in enumerate(mes):
        if(len(mes) > counter + 1 and char == 'd' and mes[counter + 1] == 'ʒ'):
            result += 'N'
        else:
            result += pholet[char] if char in pholet else ''
    print(result)
    print(f"<font face='Shage'>{result}</font>")


def main():
    while(True):
        convert(input("Enter IPA to convert"))

main()
