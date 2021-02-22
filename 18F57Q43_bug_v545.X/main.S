; see: https://www.microchip.com/forums/FindPost/1166879
processor 18F57Q43
PSECT code,abs
Start:
     bz   LabelThatDoesNotExist
     bnz  LabelThatDoesNotExist
     bc   LabelThatDoesNotExist
     bnc  LabelThatDoesNotExist
     bn   LabelThatDoesNotExist
     bnn  LabelThatDoesNotExist
     bov  LabelThatDoesNotExist
     bnov LabelThatDoesNotExist
     bra  OnlyOneThatGetsAnError

END Start