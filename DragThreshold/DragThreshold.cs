using OpenTabletDriver.Plugin.Attributes;
using OpenTabletDriver.Plugin.Tablet;
using OpenTabletDriver.Plugin.Output;
using System;
using System.Numerics;

namespace DragThreshold
{
    [PluginName("Drag Threshold")]
    public class DragThreshold : IPositionedPipelineElement<IDeviceReport>
    {
        private Vector2? _anchorPosition;
        private bool _isDragging;

        public event Action<IDeviceReport> Emit;

        public void Consume(IDeviceReport value)
        {
            if (value is ITabletReport tabletReport)
            {
                ProcessTabletReport(tabletReport);
            }

            Emit?.Invoke(value);
        }

        private void ProcessTabletReport(ITabletReport tabletReport)
        {
            bool penDown = tabletReport.Pressure > 0;

            if (penDown)
            {
                if (_anchorPosition == null)
                {
                    // Pen just went down - set anchor point
                    _anchorPosition = tabletReport.Position;
                    _isDragging = false;
                }

                if (!_isDragging)
                {
                    float distance = Vector2.Distance(tabletReport.Position, _anchorPosition.Value);

                    if (distance > Threshold)
                    {
                        // Threshold exceeded - start dragging
                        _isDragging = true;
                    }
                    else
                    {
                        // Within threshold - hold position at anchor
                        tabletReport.Position = _anchorPosition.Value;
                    }
                }
            }
            else
            {
                // Pen lifted
                // If we never started dragging, report the pen-up at the anchor position
                // This ensures mousedown and mouseup happen at the same location for apps like Electron
                if (_anchorPosition != null && !_isDragging)
                {
                    tabletReport.Position = _anchorPosition.Value;
                }

                // Reset state
                _anchorPosition = null;
                _isDragging = false;
            }
        }

        public PipelinePosition Position => PipelinePosition.PostTransform;

        [Property("Threshold"), Unit("px"), DefaultPropertyValue(5f), ToolTip
            ("Drag Threshold:\n\n" +
            "Threshold: The distance in pixels the pen must move before it is considered a drag. " +
            "Movement below this threshold will keep the cursor stationary, helping prevent accidental drags during clicks.")]
        public float Threshold { get; set; }
    }
}
