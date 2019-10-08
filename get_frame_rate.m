function freq = get_frame_rate(mouse_name)
frame_rate = containers.Map;
frame_rate('Necab_M3') = 2.3;
frame_rate('Necab_M4') = 2.3;
frame_rate('Necab_M8') = 2.3;
frame_rate('Necab_M11') = 2.3;
frame_rate('Necab_M13') = 2.3;
frame_rate('Yu_Thy1_1') = 1.3;
frame_rate('Yu_Thy1_2') = 1.3;
frame_rate('Yu_Thy1_3') = 1.1;
frame_rate('Yu_Thy1_4') = 1.3;
frame_rate('Yu_Thy1_5') = 1.3;
frame_rate('Yu_Thy1_7') = 1.3;
frame_rate('Sim_S2_1') = 2.7557;
frame_rate('Sim_S2_2') = 2.743;

freq =frame_rate(mouse_name);
end
