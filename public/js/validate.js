$(document).ready(function() {
  $('#newUserForm').bootstrapValidator({
    //        live: 'disabled',
    message: 'This value is not valid',
    feedbackIcons: {
      valid: 'glyphicon glyphicon-ok',
      invalid: 'glyphicon glyphicon-remove',
      validating: 'glyphicon glyphicon-refresh'
    },
    fields: {
      username: {
        message: 'The username is not valid',
        validators: {
          notEmpty: {
            message: 'The username is required and cannot be empty'
          },
          stringLength: {
            min: 6,
            max: 30,
            message: 'The username must be more than 6 and less than 30 characters long'
          },
          regexp: {
            regexp: /^[a-zA-Z0-9_\.]+$/,
            message: 'The username can only consist of alphabetical, number, dot and underscore'
          },
          remote: {
            type: 'POST',
            url: 'remote.php',
            message: 'The username is not available'
          },
          different: {
            field: 'password,confirmPassword',
            message: 'The username and password cannot be the same as each other'
          }
        }
      },
      email: {
        validators: {
          emailAddress: {
            message: 'The input is not a valid email address'
          }
        }
      },
      password: {
        validators: {
          notEmpty: {
            message: 'The password is required and cannot be empty'
          },
          identical: {
            field: 'confirmPassword',
            message: 'The password and its confirm are not the same'
          },
          different: {
            field: 'username',
            message: 'The password cannot be the same as username'
          },
          stringLength: {
            min: 6,
            message: 'The password must be at least 6 characters long'
          },
        }
      },
      confirmPassword: {
        validators: {
          notEmpty: {
            message: 'The confirm password is required and cannot be empty'
          },
          identical: {
            field: 'password',
            message: 'The password and its confirm are not the same'
          },
          different: {
            field: 'username',
            message: 'The password cannot be the same as username'
          },
          stringLength: {
            min: 6,
            message: 'The password must be at least 6 characters long'
          },
        }
      }
    }
  });
  $('#newArticle').bootstrapValidator({
    message: 'This value is not valid',
    feedbackIcons: {
      valid: 'glyphicon glyphicon-ok',
      invalid: 'glyphicon glyphicon-remove',
      validating: 'glyphicon glyphicon-refresh'
    },
    fields: {
      page_title: {
        validators: {
          notEmpty: {
            message: 'The title cannot be empty'
          }
        }
      },
      page_content: {
        validators: {
          notEmpty: {
            message: 'The content cannot be empty'
          }
        }
      },

    }
  });
});
