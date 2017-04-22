adore namespace
===============

This is the main Adore namespace where all the adore functions are stored.

.. note::

    You should not directly edit any values within this namespace unless you know
    what you are doing.

Function Reference
------------------

.. function:: adore.getGameDT()

    :returns: the delta time in seconds

Returns the time it took for the last frame to run. This will just be
the reciprocal of the frame rate at the moment since dynamic frame rates
are not supported.

.. function:: adore.event(name, priority, fn)

    :param string name: name of the event to hook
    :param number priority: The priority of the event, lower is more important
    :param function fn: The callback function.

The signature of the function passed to ``adore.event`` will depend on the
event hooked on to. A list of events can be found here(TODO)

.. function:: adore.getGame()

    :returns: The current game

Returns the currently loaded game object

.. function:: adore.doOnce(key)

    :param string key: A unique key
    :returns: ``true`` if the action should be performed, ``false`` otherwise.

Perform an action exactly once by querying a persistent dictionary

**Example**::

    if adore.doOnce("get banana") then
      aBill:say("I picked up the banana")
    else
      aBill:say("No, I've already picked up the banana")
    end

.. function:: adore.queryScreen(x,y)

    :param number x: The X coordinate in screen-space
    :param number y: The Y coordinate in screen-space
    :returns: The object and its type

**Example**::

    local obj, type = adore.queryScreen(mx,my)

.. function:: adore.quit()

Causes the engine to quit

.. function:: adore.wait(time)

    :param number time: The number of loops to wait

Holds the current script for the number of game loops specified. The script will
not return until the wait time has elapsed

.. function:: adore.isBlocked()

    :returns: ``true`` if blocked, ``false`` otherwise

Checks if the Adore scripting loop is currently blocked by a script action.

.. function:: adore.reloadAssets()

Causes Adore to reload all character walk sets and scene backgrounds/sprites/masks
