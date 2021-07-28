classdef BarChartRace3D < handle
    % Copyright 2021 The MathWorks, Inc.
    
    properties (Access=public)
        colors;             %colors for bars
        labels;             %labels for bars
        title;              %title
        ticks;              %horizontal ticks 
        positiveOnly;       %all values are positive. Use whole canvas
        animationFrames;    %number of frames for animation. 3d always whole canvas
        show3D;             %3D barChartRace
        axisColor;          %axisColor
        outfile;            %animation gif output
    end
    
    % private properties for internal use
    properties (Access=private)
        xlimit;
        ylimit;
        barWidth;
        maxColors;
        numBars;
        dataCount;
        gap;
        
        WidthLeft;
        EdgeLeft;
    end
    
    methods (Access=public)
        function bcr = BarChartRace3D()
            bcr.xlimit = [-400 400];
            bcr.ylimit = [-300 300];
            bcr.barWidth = 30;
            bcr.gap = 10;
            % animate 24 frames between each step
            bcr.animationFrames = 24;
            bcr.positiveOnly = false;   % default to showing both + and -
            % initialize default colors to be used
            % user can overwrite later
            bcr.colors = [
                1 0 0; ...
                0 1 0; ...
                0 0 1; ...
                1 1 0; ...
                1 0 1; ...
                0 1 1; ...
                1 0.64 0; ...
                0 0 0.55; ...
                0.5 0 0; ...
                0.7 0.8 1; ...
                1 0.71 0.76; ...
                0.9 0.9 0.98];
            bcr.WidthLeft = 30;
            bcr.EdgeLeft = 5;
            bcr.axisColor = [0.8 0.8 0.8];
            bcr.outfile = 'BarChartRace3D.gif';
        end
        
        function preDraw(obj, data)
            [obj.maxColors, ~] = size(obj.colors);
            [obj.dataCount, obj.numBars] = size(data);
            if obj.numBars > 8
                obj.barWidth = 30;
            else
                obj.barWidth = 50;
            end
        end
        
        function xScale = getXscale(obj, data, i)
            if i > obj.dataCount
                xScale = 1;
                return;
            end
            data1 = data(i, :);
            max1 = max(abs(data1));
            
            lengthMax = 350 - 110;
            if obj.positiveOnly || obj.show3D
                lengthMax = lengthMax * 2;
            end
            xScale = lengthMax/max1;
        end
        
        function [xScale1, xScale2] = computeXscales(obj, data, i)
            xScale1 = obj.getXscale(data, i);
            if i >= obj.dataCount
                % last sample
                xScale2 = xScale1;
            else
                xScale2 = obj.getXscale(data, i + 1);
            end
        end
        
        function yPos = getYpos(obj, yIndex)
            if obj.show3D
                if yIndex >= 5
                    yleft = -(obj.WidthLeft/2 + (yIndex - 5)*(obj.WidthLeft + obj.EdgeLeft));
                else
                    yleft = (obj.EdgeLeft + obj.WidthLeft/2) + (4 - yIndex)*(obj.WidthLeft + obj.EdgeLeft);
                end
                yPos = yleft;
            else    
                yPos = 250 - (obj.barWidth + obj.gap)*(yIndex - 1);  
            end
        end
        
        function drawX(obj)
            if obj.show3D
                plot([-290 260], [-138 -273], 'Color', obj.axisColor);
                plot([-290+obj.WidthLeft 260+60], [-138 -273], 'Color', obj.axisColor);
                plot([260 260+60], [-273 -273], 'Color', obj.axisColor);
            else
                plot([-290 400], [-250 -250], 'Color', obj.axisColor);
            end
        end
        
        function drawY(obj)
            if obj.show3D
                plot([-290 -290], [-138 140], 'Color', obj.axisColor);
                plot([-290+obj.WidthLeft -290+obj.WidthLeft], [-138 140], 'Color', [0.95 0.95 0.95]);
                plot([-290 -290+obj.WidthLeft], [-138 -138], 'Color', [0.90 0.90 0.90]);
            else
                if obj.positiveOnly
                    plot([-290 -290], [295 -250], 'Color', obj.axisColor);
                else
                    plot([0 0], [295 -250], 'Color', obj.axisColor);
                end
            end
        end

        function drawTitle(obj)
            if ~isempty(obj.title)
                text(0, -295, obj.title, 'FontSize', 18, 'HorizontalAlignment','center');
            end
        end
        
        function drawBar(obj, yPos, xTop, i, value)
            
            color = obj.colors(mod(i-1, obj.maxColors)+1, :);
            edgeColor = arrayfun(@(x) (x - 0.5)*(x>0.5), color);
            
            if obj.positiveOnly
                x = [-290 xTop-290 xTop-290 -290];
            else
                x = [0 xTop xTop 0];
            end
            y = [yPos - obj.barWidth/2 yPos - obj.barWidth/2 yPos + obj.barWidth/2 yPos + obj.barWidth/2]; 
            h = fill(x, y, color, 'EdgeColor', edgeColor);
            set(h,'facealpha',.5);
            if i < length(obj.labels)
                lbl = obj.labels{i};
                text(-295, yPos, lbl, 'HorizontalAlignment', 'right', 'Color', edgeColor);
                text(x(2) + 5, yPos, num2str(value), 'Color', edgeColor);
            end
        end
        
        function animateBar(obj, xInit, xEnd, yInit, yEnd, fStep, i, vInit, vEnd)
            if fStep > obj.animationFrames
                return;
            end
            
            xPos = xInit + (xEnd - xInit)*fStep/obj.animationFrames;
            yPos = yInit + (yEnd - yInit)*fStep/obj.animationFrames;
            value = vInit + (vEnd - vInit)*fStep/obj.animationFrames;
            
            if obj.show3D
                obj.drawBar3D(yPos, xPos, i, value);
            else
                obj.drawBar(yPos, xPos, i, value);
            end
        end
        
        
        function race(obj, data)
            [p, f, ~] = fileparts(obj.outfile);
            obj.outfile = fullfile(p, [f '.gif']);

            firstFrame = true;
            
            obj.preDraw(data);
            for step = 1:obj.dataCount - 1
                data_cur = data(step, :);
                [~, yCurs] = sort(data_cur, 'descend');
                
                data_next = data(step + 1, :);
                [~, yNexts] = sort(data_next, 'descend');
                
                [xScale1, xScale2] = obj.computeXscales(data, step);
                for fStep = 1:obj.animationFrames
                    clf
                    axis off
                    hold on
                    xlim(obj.xlimit);
                    ylim(obj.ylimit);

                    obj.drawX();
                    obj.drawY();
                    obj.drawTitle();
                    for barOrder = 1:obj.numBars
                        %
                        yInit = obj.getYpos(barOrder);
                        barIndex = yCurs(barOrder);
                        endIndex = find(yNexts == barIndex);
                        yEnd = obj.getYpos(endIndex);
                        
                        xInit = data_cur(barIndex)*xScale1;
                        xEnd = data_next(barIndex)*xScale2;
                        
                        vInit = data_cur(barIndex);
                        vEnd = data_next(barIndex);
                        
                        obj.animateBar(xInit, xEnd, yInit, yEnd, fStep, barIndex, vInit, vEnd);
                    end
                    
                    [img, map] = rgb2ind(frame2im( getframe(gcf)),256);
                    if firstFrame
                        imwrite(img,map,obj.outfile,'gif','DelayTime',0.5);
                        firstFrame = false;
                    else
                        imwrite(img,map,obj.outfile,'gif','writemode', 'append','delaytime',1/obj.animationFrames);
                    end
                    hold off
                end
      
            end
            
        end
        

        function drawBar3D(obj, yPos, xTop, i, value)
            yleft = yPos;
            xLen = xTop;
            
            yright = BarChartRace3D.getRightY(yleft, xLen);
            widthRight = BarChartRace3D.getRightWidth(obj.WidthLeft, xLen);
            
            colrs =  BarChartRace3D.getColors(obj.colors(mod(i-1, obj.maxColors)+1, :));
            
            %left polygon
            h = fill([-290 xLen-290 xLen-290 -290], [yleft-obj.WidthLeft/2 (yright-widthRight/2) (yright+widthRight/2) (yleft+obj.WidthLeft/2)], colrs(1, :), 'EdgeColor', colrs(5, :));            
            set(h,'facealpha',.5);
                        
            %front polygon
            h=fill([xLen-290 xLen-290+widthRight, xLen-290+widthRight, xLen-290], [yright-widthRight/2 yright-widthRight/2 yright+widthRight/2 yright+widthRight/2], colrs(2, :), 'EdgeColor', colrs(5, :));
            set(h,'facealpha',.5);
            
            if yPos < 0
                %Lower half section draw top
                h = fill([-290 xLen-290 xLen-290+widthRight -290+obj.WidthLeft], [yleft+obj.WidthLeft/2 yright+widthRight/2 yright+widthRight/2 yleft+obj.WidthLeft/2], colrs(3, :), 'EdgeColor', colrs(5, :));
            else
                h = fill([-290 xLen-290 xLen-290+widthRight -290+obj.WidthLeft], [yleft-obj.WidthLeft/2 yright-widthRight/2 yright-widthRight/2 yleft-obj.WidthLeft/2], colrs(4, :), 'EdgeColor', colrs(5, :));
            end
            set(h,'facealpha',.5);
            
            if i < length(obj.labels)
                lbl = obj.labels{i};
                text(-295, yPos, lbl, 'HorizontalAlignment', 'right', 'Color', colrs(5, :));
                text(xLen-290+widthRight + 5, yright, num2str(value), 'Color', colrs(5, :));
            end
        end
        
    end
    
    methods(Static)
        function rwidth = getRightWidth(lwidth, xLen)
            scale = (580/(580+xLen));
            rwidth = lwidth/scale;
        end
        function yright = getRightY(yleft, xLen)
            scale = (580/(580+xLen));
            yright = yleft/scale;
        end
        function colors = getColors(color)
            colors = zeros(5, 3);
            % left is the same 
            colors(1, :) = color;
            % front shall be lighter
            colors(2, :) = arrayfun(@(x) (x+0.4)*(x<0.6) + (x>=0.6), color);
            % up shall be little lighter
            colors(3, :) = arrayfun(@(x) (x+0.1)*(x<0.9) + (x>=0.9), color);
            % buttom shall be darker
            colors(4, :) = arrayfun(@(x) (x-0.2)*(x>0.2), color);
            % edge
            colors(5, :) = arrayfun(@(x) (x - 0.5)*(x>0.5), color);
        end
    end
end