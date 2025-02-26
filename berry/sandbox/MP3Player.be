class MP3_Player : Driver
    var audio_output, audio_mp3, fast_loop_closure
    def init()
      #AudioOutputI2S::AudioOutputI2S(long sampleRate, pin_size_t sck, pin_size_t data)
      #self.audio_output = AudioOutputI2S(44100, 12, 5)
      self.audio_output = AudioOutputI2S()
      #AudioOutputI2S::SetPinout(int bclk, int wclk, int dout)
      self.audio_output.setPinout(12, 4 , 5)
      self.audio_mp3 = AudioGeneratorMP3()
      self.fast_loop_closure = def () self.fast_loop() end
      tasmota.add_fast_loop(self.fast_loop_closure)
    end
  
    def play(mp3_fname)
      self.stop()
      var audio_file = AudioFileSourceFS(mp3_fname)
      self.audio_mp3.begin(audio_file, self.audio_output)
      self.audio_mp3.loop()    #- start playing now -#
    end
    
    def stop()
      if self.audio_mp3.isrunning()
        self.audio_mp3.stop()
      end
    end
  
    def fast_loop()
      if self.audio_mp3.isrunning()
        if !self.audio_mp3.loop()
          self.audio_mp3.stop()
          tasmota.remove_fast_loop(self.fast_loop_closure)
        end
      end
    end
  end

var mp3_player = MP3_Player()
mp3_player.play("/mp3/1_help.mp3")