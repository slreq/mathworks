function testBCR3D()
    clear
    clc
    close all

    bcr3 = BarChartRace3D();

    % 1. Optional configuration

    % provide labels for each bar. Default to empty
    bcr3.labels = {'a', 'b', 'c', 'd','e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p'};
    % set 3D. Default is false, showing 2D
    bcr3.show3D=true;
    % all possible data. Default to be false. Used only for 2D.
    bcr3.positiveOnly = true;
    % titile. Default to empty string
    bcr3.title = 'BarChartRace3D';
    % output file. Default tp BarChartRace3D.gif
    bcr3.outfile = 'BarChartRace3D';
    % colors. Use default if not set
    % bcr3.colors = [1 0 0; 0 1 0; 0 0 1];

    % 2. Simulate some random data
    data = rand(3, 8);

    % 3. Start the race
    bcr3.race(data);
end