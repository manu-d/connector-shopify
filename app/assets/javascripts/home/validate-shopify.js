$(document).ready(function () {
    $('#authentify-shopify').bootstrapValidator({
        feedbackIcons: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
            shop: {
                message: 'The username is not valid.',
                validators: {
                    notEmpty: {
                        message: 'The shop is mandatory'
                    },
                    callback: {
                        callback: function (value, validator, $field) {
                            value = value.trim();
                            if (!value.endsWith('.myshopify.com')){
                                return {
                                    valid: false,
                                    message: 'Your domain should ends with myshopify.com'
                                }
                            }else if (value.startsWith('http')){
                                return {
                                    valid: false,
                                    message: "Your domain should not contains the http"
                                }
                            }
                            return true;
                        }
                    }
                },
                verbose:false
            }
        }
    })
});

