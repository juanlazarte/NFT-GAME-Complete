# 🎮 NFT Game Project

Este proyecto es un juego NFT completo que incluye la creación y administración de tokens, venta pública, vault de recompensas y vesting. Utiliza tecnología blockchain para garantizar la seguridad y transparencia, integrando Chainlink para la generación de números aleatorios. Las pruebas del sistema fueron realizadas con Foundry para asegurar un código robusto y confiable.

## 🛠️ Características

- **Contrato de Token**: Implementación de un contrato ERC20/721 que permite la emisión de tokens utilizados dentro del juego.
- **Vault**: Sistema de vaults que gestiona las recompensas de los jugadores.
- **Public Sale**: Contrato que facilita la venta pública de tokens del juego.
- **Vesting**: Contrato que gestiona la liberación progresiva de los tokens adquiridos o recompensas a lo largo del tiempo.
- **Integración con Chainlink**: Utilizado para la generación segura de números aleatorios, fundamentales para la mecánica del juego (ej. loot boxes, aleatorización de atributos).
  
## 🚀 Tecnologías Utilizadas

- **Solidity**: Lenguaje utilizado para los contratos inteligentes.
- **Chainlink VRF**: Para generar números aleatorios de manera segura en la blockchain.
- **Foundry**: Framework utilizado para escribir y ejecutar tests de contratos inteligentes.
- **OpenZeppelin**: Biblioteca de contratos inteligentes para implementar estándares de ERC20/721 y características adicionales de seguridad.

## 📚 Documentación

Cada contrato está documentado en el código para explicar las funciones y el propósito de cada módulo. Puedes revisar los comentarios inline en los archivos `.sol`.


