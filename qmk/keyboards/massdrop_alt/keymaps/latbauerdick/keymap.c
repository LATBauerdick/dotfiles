#include QMK_KEYBOARD_H

enum alt_layers {
  _COLEMAK,
  _QWERTY,
  _LOWER,
  _RAISE,
  _NAV,
  _ADJ
};

enum alt_keycodes {
    U_T_AUTO = SAFE_RANGE, //USB Extra Port Toggle Auto Detect / Always Active
    U_T_AGCR,              //USB Toggle Automatic GCR control
    DBG_TOG,               //DEBUG Toggle On / Off
    DBG_MTRX,              //DEBUG Toggle Matrix Prints
    DBG_KBD,               //DEBUG Toggle Keyboard Prints
    DBG_MOU,               //DEBUG Toggle Mouse Prints
    QWERTY,                // switch to QWERTY layer
    COLEMAK,               // switch to Colemak wide layer
    MD_BOOT,               //Restart into bootloader after hold timeout
};

#define LOWER    MO(_LOWER)
#define RAISE    MO(_RAISE)
#define LOWER    MO(_LOWER)
#define ADJUST   MO(_ADJ)
#define NAV_A  LT(_NAV, KC_A)
#define NAV_O  LT(_NAV, KC_O)
#define LOW_SPC  LT(_LOWER, KC_SPC)
#define RSE_SPC  LT(_RAISE, KC_SPC)
#define ADJ_LFT  LT(_ADJ, KC_LEFT)
#define CTL_ESC  MT(MOD_LCTL, KC_ESC)
#define GUI_DEL  MT(MOD_LGUI, KC_BSPC)
#define GUI_ENT  MT(MOD_LGUI, KC_ENT)
#define RGU_SPC  MT(MOD_RGUI, KC_SPC)
#define ALT_ESC  MT(MOD_LALT, KC_ESC)
#define RSF_SLS  MT(MOD_RSFT, KC_SLSH)
#define LSF_Z    MT(MOD_LSFT, KC_Z)
#define RSF_N    MT(MOD_RSFT, KC_N)

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_COLEMAK] = LAYOUT_65_ansi_blocker( /* Colemak wide layout */
        KC_GESC, KC_1   , KC_2   , KC_3   , KC_4   , KC_5   , KC_6   , KC_7   , KC_8   , KC_9   , KC_0   , KC_MINS, KC_EQL , KC_BSPC, KC_BSPC, \
        KC_TAB , KC_Q   , KC_W   , KC_F   , KC_P   , KC_B   , KC_QUOT, KC_J   , KC_L   , KC_U   , KC_Y   , KC_LBRC, KC_RBRC, KC_BSLS, KC_HOME, \
        CTL_ESC, NAV_A  , KC_R   , KC_S   , KC_T   , KC_G   , KC_SCLN, KC_M   , KC_N   , KC_E   , KC_I   , KC_O   ,          XXXXXXX, KC_PGUP, \
        KC_LSFT, KC_Z   , KC_X   , KC_C   , KC_D   , KC_V   , KC_SLSH, KC_K   , KC_H   , KC_COMM, KC_DOT ,          RSF_SLS, KC_ENT , KC_PGDN, \
        KC_HYPR, ALT_ESC, GUI_ENT,                            RSE_SPC,                            RGU_SPC, ADJ_LFT, KC_DOWN, KC_UP  , KC_RGHT  \
    ),
    [_QWERTY] = LAYOUT_65_ansi_blocker(
        KC_GESC, KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_MINS, KC_EQL,  KC_BSPC, KC_BSPC, \
        KC_TAB , KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,    KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_LBRC, KC_RBRC, KC_BSLS, KC_HOME, \
        CTL_ESC, KC_A   , KC_S,    KC_D,    KC_F,    KC_G,    KC_H,    KC_J,    KC_K,    KC_L,    KC_SCLN, KC_QUOT,          KC_ENT , KC_PGUP, \
        KC_LSFT, KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,    KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH,          KC_RSFT, KC_UP  , ADJUST , \
        KC_HYPR, ALT_ESC, GUI_ENT,                            RSE_SPC,                            RGU_SPC, ADJ_LFT, KC_LEFT, KC_DOWN, KC_RGHT  \
    ),
    [_LOWER] = LAYOUT_65_ansi_blocker(
        KC_TILD, KC_EXLM, KC_AT ,  KC_HASH, KC_DLR , KC_PERC, KC_CIRC, KC_EQL , KC_1   , KC_2   , KC_3   , KC_ASTR, KC_MINS, _______, _______, \
        _______, KC_EXLM, KC_HOME, KC_PGUP, KC_PGDN, KC_END , XXXXXXX, KC_PERC, KC_4   , KC_5   , KC_6   , KC_PLUS, KC_LPRN, KC_RPRN, _______, \
        _______, KC_BSPC, KC_LEFT, KC_UP  , KC_DOWN, KC_RGHT, KC_ESC , KC_DLR , KC_7   , KC_8   , KC_9   , KC_ENT ,          _______, _______, \
        _______, G(KC_Z), G(KC_X), G(KC_C), G(KC_V), KC_COMM, XXXXXXX, KC_COLN, KC_0   , KC_0   , _______,          _______, _______, _______, \
        _______, _______, _______,                            _______,                            KC_0   , KC_DOT , _______, _______, _______  \
    ),
    [_RAISE] = LAYOUT_65_ansi_blocker(
        KC_GRV , KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_F11,  KC_F12 , _______, _______, \
        _______, KC_EXLM, KC_AT  , KC_HASH, KC_DLR , KC_PERC, XXXXXXX, KC_CIRC, KC_AMPR, KC_ASTR, KC_PLUS, KC_COLN, KC_GRV , _______, _______, \
        _______, KC_1   , KC_2   , KC_3   , KC_4   , KC_5   , XXXXXXX, KC_6   , KC_7   , KC_8   , KC_9   , KC_0   ,          KC_ENT , _______, \
        _______, KC_LBRC, KC_RBRC, KC_MINS, KC_EQL , KC_LPRN, XXXXXXX, KC_RPRN, KC_QUOT, _______, _______,          _______, _______, _______, \
        _______, _______, _______,                            _______,                            _______, _______, _______, _______, _______  \
    ),
    [_NAV] = LAYOUT_65_ansi_blocker(
        KC_GESC, S(KC_1), S(KC_2), S(KC_3), S(KC_4), S(KC_5), S(KC_6), S(KC_7), S(KC_8), S(KC_9), S(KC_0),S(KC_MINS),S(KC_EQL),KC_BSPC,KC_BSPC, \
        XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_RBRC, S(KC_J), XXXXXXX, XXXXXXX, XXXXXXX, KC_LBRC, KC_RBRC, KC_BSLS, _______, \
        _______, XXXXXXX, KC_HOME, KC_PGUP, KC_PGDN, KC_END,  KC_COLN, KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT, KC_ENT ,          KC_ENT , KC_BRMU, \
        _______, G(KC_Z), G(KC_X), G(KC_C), G(KC_D), G(KC_V), KC_BSPC, KC_BSPC, KC_LEFT, XXXXXXX, XXXXXXX,          _______, KC_VOLU, KC_BRMD, \
        _______, _______, _______,                            _______,                            _______, _______, _______, KC_VOLD, _______  \
    ),
    [_ADJ] = LAYOUT_65_ansi_blocker(
        KC_GRV,  KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_F11,  KC_F12,  _______, KC_MUTE, \
        _______, RGB_SPD, RGB_VAI, RGB_SPI, RGB_HUI, RGB_SAI, _______, U_T_AUTO,U_T_AGCR,_______, KC_PSCR, KC_SLCK, KC_PAUS, _______, KC_END , \
        _______, RGB_RMOD,RGB_VAD, RGB_MOD, RGB_HUD, RGB_SAD, _______, QWERTY , XXXXXXX, COLEMAK, _______, _______,          _______, KC_VOLU, \
        _______, RGB_TOG, _______, _______, _______, MD_BOOT, NK_TOGG, DBG_TOG, _______, _______, _______,          _______, KC_PGUP, KC_VOLD, \
        RESET  , _______, _______,                            _______,                            _______, _______, KC_HOME, KC_PGDN, KC_END  \
    ),
    /*
    [X] = LAYOUT(
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, \
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, \
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______,          _______, _______, \
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______,          _______, _______, \
        _______, _______, _______,                            _______,                            _______, _______, _______, _______, _______  \
    ),
    */
};

#define MODS_SHIFT  (get_mods() & MOD_BIT(KC_LSHIFT) || get_mods() & MOD_BIT(KC_RSHIFT))
#define MODS_CTRL  (get_mods() & MOD_BIT(KC_LCTL) || get_mods() & MOD_BIT(KC_RCTRL))
#define MODS_ALT  (get_mods() & MOD_BIT(KC_LALT) || get_mods() & MOD_BIT(KC_RALT))

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    static uint32_t key_timer;

    switch (keycode) {
        case QWERTY:
          if (record->event.pressed) {
            set_single_persistent_default_layer(_QWERTY);
          }
          return false;
        case COLEMAK:
          if (record->event.pressed) {
            set_single_persistent_default_layer(_COLEMAK);
          }
          return false;
        case U_T_AUTO:
            if (record->event.pressed && MODS_SHIFT && MODS_CTRL) {
                TOGGLE_FLAG_AND_PRINT(usb_extra_manual, "USB extra port manual mode");
            }
            return false;
        case U_T_AGCR:
            if (record->event.pressed && MODS_SHIFT && MODS_CTRL) {
                TOGGLE_FLAG_AND_PRINT(usb_gcr_auto, "USB GCR auto mode");
            }
            return false;
        case DBG_TOG:
            if (record->event.pressed) {
                TOGGLE_FLAG_AND_PRINT(debug_enable, "Debug mode");
            }
            return false;
        case DBG_MTRX:
            if (record->event.pressed) {
                TOGGLE_FLAG_AND_PRINT(debug_matrix, "Debug matrix");
            }
            return false;
        case DBG_KBD:
            if (record->event.pressed) {
                TOGGLE_FLAG_AND_PRINT(debug_keyboard, "Debug keyboard");
            }
            return false;
        case DBG_MOU:
            if (record->event.pressed) {
                TOGGLE_FLAG_AND_PRINT(debug_mouse, "Debug mouse");
            }
            return false;
        case MD_BOOT:
            if (record->event.pressed) {
                key_timer = timer_read32();
            } else {
                if (timer_elapsed32(key_timer) >= 500) {
                    reset_keyboard();
                }
            }
            return false;
        case RGB_TOG:
            if (record->event.pressed) {
              switch (rgb_matrix_get_flags()) {
                case LED_FLAG_ALL: {
                    rgb_matrix_set_flags(LED_FLAG_KEYLIGHT | LED_FLAG_MODIFIER | LED_FLAG_INDICATOR);
                    rgb_matrix_set_color_all(0, 0, 0);
                  }
                  break;
                case (LED_FLAG_KEYLIGHT | LED_FLAG_MODIFIER | LED_FLAG_INDICATOR): {
                    rgb_matrix_set_flags(LED_FLAG_UNDERGLOW);
                    rgb_matrix_set_color_all(0, 0, 0);
                  }
                  break;
                case LED_FLAG_UNDERGLOW: {
                    rgb_matrix_set_flags(LED_FLAG_NONE);
                    /* rgb_matrix_disable_noeeprom(); */
                    rgb_matrix_disable();
                  }
                  break;
                default: {
                    rgb_matrix_set_flags(LED_FLAG_ALL);
                    rgb_matrix_enable_noeeprom();
                  }
                  break;
              }
            }
            return false;
        default:
            return true; //Process all other keycodes normally
    }
}
