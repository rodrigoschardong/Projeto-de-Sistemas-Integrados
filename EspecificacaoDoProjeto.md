Rodrigo Schardong, 

Alison Lopes, 

**Projeto de Sistemas Integrados** UERGS - Guaíba

**Introdução ao Projeto**

O projeto nesta disciplina tem como objetivo projetar um sistema integrado responsável por controlar um carrinho que utiliza um sistema de controle para desviar da seguinte pista abaixo:![img](https://lh4.googleusercontent.com/qsuyDT5ylznt1MZwGiHyvg38Bj8C3LjvCYalcKTt9BoXBn7kSJwC1EHsrkTy7n5NWSOZWAgb2buFQ2rv5QhzFvI7HRcXEvkAKOnqVOsgMWSiCKjudE9JtvT2V-OdS7JM5l2DTC3p)

​	Assim o carrinho deve andar em linha reta paralelamente a uma parede com uma distância de 20cm dela. Ao se aproximar da parede, o carrinho deve adaptar sua rota para manter a rota a sua distância de 20 cm da parede. Do mesmo modo, ao se afastar da parede, o carrinho deve, também, se adaptar a uma nova rota.O carrinho também deve permitir uma comunicação ble (*Bluetooth Low Energy*) com um celular para observar a velocidade do carrinho, se ele está seguindo a parede, ou se ele está procurando uma nova rota.

**Especificação do Projeto**

Para o carrinho conseguir andar, é necessário gerar um sinal de saída PWM para cada motor responsável por girar as rodas do carrinho e assim definir sua velocidade e a direção.Para o carrinho manter a distância de 20cm da parede, será utilizado o sensor de distância ultrassônico HC-SR04 Para a comunicação bluetooth com um celular, será utilizado o módulo ble DA4531mod no qual obedece comandos ATs na serial.