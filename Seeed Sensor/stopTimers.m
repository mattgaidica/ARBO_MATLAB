function stopTimers()

% Delete all timers from memory.
listOfTimers = timerfindall;
if ~isempty(listOfTimers)
    delete(listOfTimers(:));
end