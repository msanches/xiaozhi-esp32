#!/usr/bin/env python3
"""
Script para Verificar Configuração do ESP32
Conecta ao ESP32 via serial e mostra as configurações do servidor
"""

import serial
import serial.tools.list_ports
import sys
import time

def list_ports():
    """Lista todas as portas seriais disponíveis"""
    ports = serial.tools.list_ports.comports()
    return [(port.device, port.description) for port in ports]

def read_settings(port, baudrate=115200):
    """Lê configurações do ESP32"""
    print(f"Conectando a {port} (baud: {baudrate})...")
    
    try:
        ser = serial.Serial(port, baudrate, timeout=2)
        time.sleep(1)  # Aguardar conexão
        
        # Limpar buffer
        ser.flushInput()
        ser.flushOutput()
        
        commands = [
            ("URL do Servidor", "AT+URL?\r\n"),
            ("Token", "AT+TOKEN?\r\n"),
            ("Versão do Firmware", "AT+VERSION?\r\n"),
        ]
        
        print("\n" + "="*60)
        print("Configurações do ESP32:")
        print("="*60 + "\n")
        
        for name, cmd in commands:
            ser.write(cmd.encode())
            time.sleep(0.5)
            
            response = ""
            while ser.in_waiting:
                response += ser.read(ser.in_waiting).decode('utf-8', errors='ignore')
                time.sleep(0.1)
            
            print(f"{name}:")
            if response.strip():
                print(f"  {response.strip()}")
            else:
                print(f"  (sem resposta)")
            print()
        
        print("="*60)
        print("\nℹ️  NOTA: Se não houver resposta, o ESP32 pode não suportar")
        print("   comandos AT ou você precisa entrar no modo de configuração.")
        print("\n💡 DICA: Verifique os logs no monitor serial para ver")
        print("   a URL do servidor durante a conexão.")
        
        ser.close()
        
    except serial.SerialException as e:
        print(f"❌ Erro ao conectar: {e}")
        return False
    
    return True

def main():
    print("🔍 Verificador de Configuração ESP32\n")
    
    # Listar portas disponíveis
    ports = list_ports()
    
    if not ports:
        print("❌ Nenhuma porta serial encontrada!")
        print("\nVerifique:")
        print("  1. ESP32 está conectado via USB")
        print("  2. Drivers estão instalados")
        print("  3. Cabo USB funciona para dados (não só carga)")
        return
    
    print("Portas seriais disponíveis:\n")
    for i, (port, desc) in enumerate(ports, 1):
        print(f"  {i}. {port} - {desc}")
    
    # Selecionar porta
    if len(sys.argv) > 1:
        port = sys.argv[1]
    else:
        print("\nEscolha a porta (ou pressione Enter para usar a primeira):", end=" ")
        try:
            choice = input().strip()
            if choice:
                idx = int(choice) - 1
                port = ports[idx][0]
            else:
                port = ports[0][0]
        except (ValueError, IndexError):
            print("❌ Escolha inválida")
            return
    
    # Ler configurações
    print()
    if not read_settings(port):
        print("\n💡 Alternativa: Use o Monitor Serial do ESP-IDF:")
        print(f"   idf.py monitor -p {port}")
        print("\n   Procure por linhas como:")
        print("   'Connecting to websocket server: ws://...'")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⏹️  Interrompido pelo usuário")
