
eir_sersor_Read_OBJ_temp:

;eir_sersor.mbas,32 :: 		sub procedure Read_OBJ_temp()
;eir_sersor.mbas,34 :: 		I2C1_Start() '//' issue I2C start signal
	CALL       _I2C1_Start+0
;eir_sersor.mbas,35 :: 		I2C1_Wr(MLX90614_ADDR) '//' send address (device address + W)
	MOVLW      90
	MOVWF      FARG_I2C1_Wr_data_+0
	CALL       _I2C1_Wr+0
;eir_sersor.mbas,36 :: 		I2C1_Wr(MLX90614_TOBJ1) '//' send command
	MOVLW      7
	MOVWF      FARG_I2C1_Wr_data_+0
	CALL       _I2C1_Wr+0
;eir_sersor.mbas,37 :: 		I2C1_Repeated_Start() '//' issue I2C signal repeated start
	CALL       _I2C1_Repeated_Start+0
;eir_sersor.mbas,38 :: 		I2C1_Wr(MLX90614_ADDR OR 0x01) '//' send address (device address + R)
	MOVLW      91
	MOVWF      FARG_I2C1_Wr_data_+0
	CALL       _I2C1_Wr+0
;eir_sersor.mbas,40 :: 		SensorLow = I2C1_Rd(1) '//' Read temp. low byte (acknowledge) PIC FREEZES
	MOVLW      1
	MOVWF      FARG_I2C1_Rd_ack+0
	CALL       _I2C1_Rd+0
	MOVF       R0+0, 0
	MOVWF      _SensorLow+0
;eir_sersor.mbas,41 :: 		SensorHigh = I2C1_Rd(1)'//' Read temp. high byte (acknowledge) PIC FREEZES
	MOVLW      1
	MOVWF      FARG_I2C1_Rd_ack+0
	CALL       _I2C1_Rd+0
	MOVF       R0+0, 0
	MOVWF      _SensorHigh+0
;eir_sersor.mbas,42 :: 		PEC = I2C1_Rd(1) ' Read PEC (not used) (acknowledge) PIC FREEZES
	MOVLW      1
	MOVWF      FARG_I2C1_Rd_ack+0
	CALL       _I2C1_Rd+0
	MOVF       R0+0, 0
	MOVWF      _PEC+0
;eir_sersor.mbas,43 :: 		I2C1_Stop() ' issue I2C stop signal
	CALL       _I2C1_Stop+0
;eir_sersor.mbas,45 :: 		SensorRaw = SensorLow OR (SensorHigh <<8 )' //' Build temp. word
	MOVF       _SensorHigh+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       R0+0, 0
	IORWF      _SensorLow+0, 0
	MOVWF      _SensorRaw+0
	MOVLW      0
	IORWF      R0+1, 0
	MOVWF      _SensorRaw+1
	RETURN
; end of eir_sersor_Read_OBJ_temp

eir_sersor_Convert_raw:

;eir_sersor.mbas,48 :: 		sub procedure Convert_raw()
;eir_sersor.mbas,50 :: 		Sensor = SensorRaw * 0.02 - 273.15 ' Raw temp to Celsius
	MOVF       _SensorRaw+0, 0
	MOVWF      R0+0
	MOVF       _SensorRaw+1, 0
	MOVWF      R0+1
	CALL       _Word2Double+0
	MOVLW      10
	MOVWF      R4+0
	MOVLW      215
	MOVWF      R4+1
	MOVLW      35
	MOVWF      R4+2
	MOVLW      121
	MOVWF      R4+3
	CALL       _Mul_32x32_FP+0
	MOVLW      51
	SUBWF      R0+0, 1
	BTFSS      STATUS+0, 0
	DECF       R0+1, 1
	MOVLW      147
	SUBWF      R0+1, 1
	MOVF       R0+0, 0
	MOVWF      _Sensor+0
	MOVF       R0+1, 0
	MOVWF      _Sensor+1
;eir_sersor.mbas,52 :: 		WordToStr(Sensor, SensorString)
	MOVF       R0+0, 0
	MOVWF      FARG_WordToStr_input+0
	MOVF       R0+1, 0
	MOVWF      FARG_WordToStr_input+1
	MOVLW      _SensorString+0
	MOVWF      FARG_WordToStr_output+0
	CALL       _WordToStr+0
	RETURN
; end of eir_sersor_Convert_raw

_main:

;eir_sersor.mbas,58 :: 		main:
;eir_sersor.mbas,61 :: 		ANSEL=0
	CLRF       ANSEL+0
;eir_sersor.mbas,62 :: 		ANSELH=0
	CLRF       ANSELH+0
;eir_sersor.mbas,63 :: 		TRISB=0
	CLRF       TRISB+0
;eir_sersor.mbas,64 :: 		PORTB=0
	CLRF       PORTB+0
;eir_sersor.mbas,66 :: 		I2C1_Init(100000) '//' I2C/SMBus Clock speed 100 kHz
	MOVLW      20
	MOVWF      SSPADD+0
	CALL       _I2C1_Init+0
;eir_sersor.mbas,67 :: 		SETBIT(SSPSTAT, 6) '//' Force MSSP in SMBus mode
	BSF        SSPSTAT+0, 6
;eir_sersor.mbas,69 :: 		Lcd_init()
	CALL       _Lcd_Init+0
;eir_sersor.mbas,70 :: 		Lcd_Cmd(_LCD_CLEAR)
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;eir_sersor.mbas,71 :: 		Lcd_Cmd(_LCD_CURSOR_OFF)
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;eir_sersor.mbas,72 :: 		loop:
L__main_loop:
;eir_sersor.mbas,73 :: 		Read_OBJ_temp() '//' Read temp.
	CALL       eir_sersor_Read_OBJ_temp+0
;eir_sersor.mbas,74 :: 		Convert_raw()
	CALL       eir_sersor_Convert_raw+0
;eir_sersor.mbas,75 :: 		Lcd_Out(1,1,"object temp")
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _main_Local_Text+0
	MOVWF      FSR
	MOVLW      111
	MOVWF      INDF+0
	INCF       FSR, 1
	MOVLW      98
	MOVWF      INDF+0
	INCF       FSR, 1
	MOVLW      106
	MOVWF      INDF+0
	INCF       FSR, 1
	MOVLW      101
	MOVWF      INDF+0
	INCF       FSR, 1
	MOVLW      99
	MOVWF      INDF+0
	INCF       FSR, 1
	MOVLW      116
	MOVWF      INDF+0
	INCF       FSR, 1
	MOVLW      32
	MOVWF      INDF+0
	INCF       FSR, 1
	MOVLW      116
	MOVWF      INDF+0
	INCF       FSR, 1
	MOVLW      101
	MOVWF      INDF+0
	INCF       FSR, 1
	MOVLW      109
	MOVWF      INDF+0
	INCF       FSR, 1
	MOVLW      112
	MOVWF      INDF+0
	INCF       FSR, 1
	CLRF       INDF+0
	INCF       FSR, 1
	MOVLW      _main_Local_Text+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;eir_sersor.mbas,76 :: 		Lcd_Out(2,2,SensorString)
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _SensorString+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;eir_sersor.mbas,78 :: 		delay_ms(500)
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L__main4:
	DECFSZ     R13+0, 1
	GOTO       L__main4
	DECFSZ     R12+0, 1
	GOTO       L__main4
	DECFSZ     R11+0, 1
	GOTO       L__main4
	NOP
	NOP
;eir_sersor.mbas,79 :: 		Lcd_Cmd(_LCD_CLEAR)
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;eir_sersor.mbas,80 :: 		goto loop
	GOTO       L__main_loop
	GOTO       $+0
; end of _main
