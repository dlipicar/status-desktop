# -*- coding: utf-8 -*-

# ******************************************************************************
# Status.im
# *****************************************************************************/
# /**
# * \file    steps.py
# *
# * \test    Status Desktop - Login
# * \date    February 2022
# * \brief   This file contains snippets of script code to be executed as the .feature
# *          file is processed.
# *          The decorators Given/When/Then/Step can be used to associate a script snippet
# *          with a pattern which is matched against the steps being executed.
# *****************************************************************************
from common.Common import *
import time

from steps.startupSteps import *
from screens.StatusMainScreen import StatusMainScreen
from screens.StatusChatScreen import StatusChatScreen

_statusMain = StatusMainScreen()
_statusChat = StatusChatScreen()

#########################
### PRECONDITIONS region:
#########################

@Given("the user starts the application with a specific data folder \"|any|\"")
def step(context, data_folder_path):
    a_user_starts_the_application_with_a_specific_data_folder(context, data_folder_path)

@Given("the user restarts the app")
def step(context):
    the_user_restarts_the_app(context)
    
@Given("the user joins chat room \"|any|\"")
def step(context, room):
    the_user_joins_chat_room(room)

@Given("the user clicks on escape key")
def step(context):
    _statusMain.click_escape()    

#########################
### ACTIONS region:
#########################

@When("the user restarts the app")
def step(context):
    the_user_restarts_the_app(context)
    
@When("user inputs the following |any| with ui-component |any|")
def step(context, text, obj):
    input_text(text, obj)

@When("user clicks on the following ui-component |any|")
def step(context: any, obj: str):
    the_user_clicks_on_the_following_ui_component(obj)

@When("the user joins chat room \"|any|\"")
def step(context, room):
    the_user_joins_chat_room(room)

#########################
### VERIFICATIONS region:
#########################

@Then("the following ui-component |any| is not enabled")
def step(context, obj):
    object_not_enabled(obj)
    
###########################################################################
### COMMON methods used in different steps given/when/then region:
###########################################################################

def the_user_restarts_the_app(context: any):
    waitFor(lambda: currentApplicationContext().detach(), 500)
    time.sleep(5)
    startApplication(context.userData["aut_name"])
    
def the_user_joins_chat_room(room: str):
    the_user_joins_chat_room(room)
