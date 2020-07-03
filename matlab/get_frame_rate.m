function freq = get_frame_rate(mouse_name)
% Returns frame rate for the calcium imaging recording for a particular mouse.
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
frame_rate('001') = 10.8;

if frame_rate.isKey(mouse_name)
    freq = frame_rate(mouse_name);
else
    freq = 3.05;
end
end
