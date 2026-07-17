_: {
  # ── Generate Monitor Settings ───────────
  xdg.configFile."monitors.xml".text = ''
    <monitors version="2">
      <configuration>
        <layoutmode>logical</layoutmode>
        <logicalmonitor>
          <x>0</x>
          <y>0</y>
          <scale>2</scale>
          <primary>yes</primary>
          <monitor>
            <monitorspec>
              <connector>eDP-2</connector>
              <vendor>SDC</vendor>
              <product>ATNA40CU05-0 </product>
              <serial>0x00000000</serial>
            </monitorspec>
            <mode>
              <width>2880</width>
              <height>1800</height>
              <rate>60.001</rate>
            </mode>
          </monitor>
        </logicalmonitor>
      </configuration>
    </monitors>
  '';
}
