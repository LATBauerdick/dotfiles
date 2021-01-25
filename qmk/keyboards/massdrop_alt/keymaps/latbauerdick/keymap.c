#include QMK_KEYBOARD_H

enum alt_layers {
  _CLMK_WD,
  _QWERTY,
  _COLEMAK,
  /* _INVCMWD, */
  _LOWER,
  _RAISE,
  _NAV,
  _LOW_WD,
  _RSE_WD,
  _NAV_WD,
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
    COLEMAK,               // switch to Colemak layer
    CLMK_WD,               // switch to Colemak wide layer
    MD_BOOT,               //Restart into bootloader after hold timeout
};

#define LOWER    MO(_LOWER)
#define RAISE    MO(_RAISE)
#define RSE_WD   MO(_RSE_WD)
#define LOW_WD   MO(_LOW_WD)
/* #define INVCMWD  MO(_INVCMWD) */
#define NAV_A    LT(_NAV, KC_A)
#define NAV_O    LT(_NAV, KC_O)
#define NAVWD_A  LT(_NAV_WD, KC_A)
#define NAVWD_O  LT(_NAV_WD, KC_O)
#define NWD_QUOT LT(_NAV_WD, KC_QUOT)
#define LOW_SPC  LT(_LOWER, KC_SPC)
#define RSE_SPC  LT(_RAISE, KC_SPC)
#define RWD_SPC  LT(_RSE_WD, KC_SPC)
#define ADJ_SPC  LT(_ADJ, KC_SPC)
#define CTL_ESC  MT(MOD_LCTL, KC_ESC)
#define GUI_DEL  MT(MOD_LGUI, KC_BSPC)
#define GUI_RET  MT(MOD_RGUI, KC_ENT)
#define RSF_SLS  MT(MOD_RSFT, KC_SLSH)
#define RSF_N    MT(MOD_RSFT, KC_N)

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_QWERTY] = LAYOUT_65_ansi_blocker(
        KC_GESC, KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_MINS, KC_EQL,  KC_BSPC, KC_BSPC, \
        KC_TAB , KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,    KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_LBRC, KC_RBRC, KC_BSLS, KC_HOME, \
        CTL_ESC, NAVWD_A, KC_S,    KC_D,    KC_F,    KC_G,    KC_H,    KC_J,    KC_K,    KC_L,    KC_SCLN, NWD_QUOT,         KC_ENT,  KC_PGUP, \
        KC_LSFT, KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,    KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH, KC_RSFT,          KC_UP,   KC_ENT,  \
        RAISE  , KC_LALT, GUI_DEL,                            RSE_SPC,                            GUI_RET, ADJ_SPC, KC_LEFT, KC_DOWN, KC_RGHT  \
    ),
    [_CLMK_WD] = LAYOUT_65_ansi_blocker( /* Colemak wide layout */
        KC_GESC, KC_1   , KC_2   , KC_3   , KC_4   , KC_5   , KC_6   , KC_EQL , KC_7   , KC_8   , KC_9   , KC_0   , KC_MINS, KC_BSPC, KC_BSPC, \
        KC_TAB , KC_Q   , KC_W   , KC_F   , KC_P   , KC_B   , KC_LBRC, KC_J   , KC_L   , KC_U   , KC_Y   , KC_SCLN, KC_QUOT, KC_BSLS, KC_HOME, \
        CTL_ESC, NAVWD_A, KC_R   , KC_S   , KC_T   , KC_G   , KC_RBRC, KC_M   , KC_N   , KC_E   , KC_I   , NAVWD_O,          KC_ENT,  KC_PGUP, \
        KC_LSFT, KC_X   , KC_C   , KC_D   , KC_V   , KC_Z   , KC_SLSH, KC_K   , KC_H   , KC_COMM, KC_DOT , RSF_SLS,          KC_UP,   KC_ENT , \
        RSE_WD , KC_LALT, GUI_DEL,                            RWD_SPC,                            GUI_RET, ADJ_SPC, KC_LEFT, KC_DOWN, KC_RGHT  \
    ),
    [_COLEMAK] = LAYOUT_65_ansi_blocker( /* Colemak */
        _______, _______, _______, _______, _______, _______, _______, KC_7   , KC_8   , KC_9   , KC_0   , KC_MINS, KC_EQL , _______, _______, \
        _______, KC_Q   , KC_W   , KC_F   , KC_P   , KC_B   , KC_J   , KC_L   , KC_U   , KC_Y   , KC_SCLN, KC_LBRC, KC_RBRC, _______, _______, \
        _______, NAV_A  , KC_R   , KC_S   , KC_T   , KC_G   , KC_M   , KC_N   , KC_E   , KC_I   , NAV_O  , KC_QUOT,          _______, _______, \
        _______, KC_Z   , KC_X   , KC_C   , KC_D   , KC_V   , KC_K   , KC_H   , _______, _______, _______, RSF_SLS,          _______, _______, \
        LOWER  , _______, _______,                            RSE_SPC,                            GUI_RET, _______, _______, _______, _______  \
    ),
    /* [_INVCMWD] = LAYOUT_65_ansi_blocker( /1* inverse Colemak DH wide *1/ */
    /*     _______, _______, _______, _______, _______, _______, _______, KC_8   , KC_9   , KC_0   , KC_MINS, KC_EQL , KC_7   , _______, _______, \ */
    /*     _______, _______, _______, KC_L   , KC_S   , KC_F   , KC_P   , KC_O   , KC_SCLN, KC_QUOT, KC_R   , KC_Y   , KC_H   , _______, _______, \ */
    /*     _______, _______, KC_D   , KC_C   , KC_E   , _______, KC_COMM, KC_U   , KC_M   , KC_I   , KC_LBRC, KC_RBRC,          _______, _______, \ */
    /*     _______, KC_B   , KC_Z   , KC_X   , KC_V   , KC_T   , KC_K   , KC_J   , KC_DOT , KC_SLSH, KC_N   , _______,          _______, _______, \ */
    /*     _______, _______, _______,                            _______,                            _______, _______, _______, _______, _______  \ */
    /* ), */
    [_LOWER] = LAYOUT_65_ansi_blocker(
        KC_TILD, KC_EXLM, KC_AT ,  KC_HASH, KC_DLR , KC_PERC, KC_CIRC, KC_7   , KC_8   , KC_9   , KC_ASTR, _______, _______, _______, _______, \
        _______, KC_EXLM, KC_HOME, KC_PGUP, KC_PGDN, KC_END , KC_PERC, KC_4   , KC_5   , KC_6   , KC_PLUS, KC_LPRN, KC_RPRN, _______, _______, \
        _______, KC_BSPC, KC_LEFT, KC_UP  , KC_DOWN, KC_RGHT, KC_DLR , KC_1   , KC_2   , KC_3   , KC_ENT , _______,          _______, _______, \
        _______, G(KC_Z), G(KC_X), G(KC_C), G(KC_V), KC_COMM, KC_COLN, KC_0   , KC_0   , _______, _______, _______,          _______, _______, \
        _______, _______, _______,                            _______,                            KC_0   , KC_DOT , _______, _______, _______  \
    ),
    [_LOW_WD] = LAYOUT_65_ansi_blocker(
        KC_TILD, KC_EXLM, KC_AT ,  KC_HASH, KC_DLR , KC_PERC, KC_CIRC, KC_EQL , KC_1   , KC_2   , KC_3   , KC_ASTR, KC_MINS, _______, _______, \
        _______, KC_EXLM, KC_HOME, KC_PGUP, KC_PGDN, KC_END , XXXXXXX, KC_PERC, KC_4   , KC_5   , KC_6   , KC_PLUS, KC_LPRN, KC_RPRN, _______, \
        _______, KC_BSPC, KC_LEFT, KC_UP  , KC_DOWN, KC_RGHT, KC_ESC , KC_DLR , KC_7   , KC_8   , KC_9   , KC_ENT ,          _______, _______, \
        _______, G(KC_Z), G(KC_X), G(KC_C), G(KC_V), KC_COMM, XXXXXXX, KC_COLN, KC_0   , KC_0   , _______, _______,          _______, _______, \
        _______, _______, _______,                            _______,                            KC_0   , KC_DOT , _______, _______, _______  \
    ),
    [_RAISE] = LAYOUT_65_ansi_blocker(
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, KC_Y   , KC_H   , KC_7   , _______, _______, \
        KC_GRV , S(KC_1), S(KC_2), S(KC_3), S(KC_4), S(KC_5), S(KC_7), S(KC_6), S(KC_8), S(KC_9), S(KC_0), KC_Y   , KC_H   , _______, _______, \
        _______, KC_1   , KC_2   , KC_3   , KC_4   , KC_5   , KC_7   , KC_6   , KC_8   , KC_9   , KC_0   , KC_MINS,          _______, _______, \
        _______, KC_Y   , KC_H   , KC_EQL , KC_7   , S(KC_0), KC_N   ,S(KC_MINS),KC_RBRC, KC_DOT , KC_SLSH, _______,          _______, _______, \
        _______, _______, _______,                            _______,                            _______, _______, _______, _______, _______  \
    ),
    [_RSE_WD] = LAYOUT_65_ansi_blocker(
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, \
        KC_GRV , KC_EXLM, KC_AT  , KC_HASH, KC_DLR , KC_PERC, XXXXXXX, KC_CIRC, KC_AMPR, KC_ASTR, KC_PLUS, KC_COLN, _______, _______, _______, \
        _______, KC_1   , KC_2   , KC_3   , KC_4   , KC_5   , XXXXXXX, KC_6   , KC_7   , KC_8   , KC_9   , KC_0   ,          _______, _______, \
        _______, KC_LBRC, KC_RBRC, KC_MINS, KC_EQL , KC_LPRN, XXXXXXX, KC_RPRN, KC_QUOT, _______, _______, _______,          _______, _______, \
        _______, _______, _______,                            _______,                            _______, _______, _______, _______, _______  \
    ),
    [_NAV] = LAYOUT_65_ansi_blocker(
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, \
        XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, _______, _______, _______, \
        _______, XXXXXXX, KC_HOME, KC_PGUP, KC_PGDN, KC_END,  KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT, XXXXXXX, _______,          _______, KC_BRMU, \
        _______, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_BSPC, KC_LEFT, XXXXXXX, XXXXXXX, XXXXXXX, _______,          KC_VOLU, KC_BRMD, \
        _______, _______, _______,                            _______,                            _______, _______, _______, KC_VOLD, _______  \
    ),
    [_NAV_WD] = LAYOUT_65_ansi_blocker(
        KC_GESC, S(KC_1), S(KC_2), S(KC_3), S(KC_4), S(KC_5), S(KC_6), S(KC_7), S(KC_8), S(KC_9), S(KC_0),S(KC_MINS),S(KC_EQL),KC_BSPC,KC_BSPC, \
        XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, _______, _______, _______, \
        _______, XXXXXXX, KC_HOME, KC_PGUP, KC_PGDN, KC_END,  XXXXXXX, KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT, XXXXXXX,          _______, KC_BRMU, \
        _______, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_BSPC, KC_LEFT, XXXXXXX, XXXXXXX, _______,          KC_VOLU, KC_BRMD, \
        _______, _______, _______,                            _______,                            _______, _______, _______, KC_VOLD, _______  \
    ),
    [_ADJ] = LAYOUT_65_ansi_blocker(
        KC_GRV,  KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_F11,  KC_F12,  _______, KC_MUTE, \
        _______, RGB_SPD, RGB_VAI, RGB_SPI, RGB_HUI, RGB_SAI, _______, U_T_AUTO,U_T_AGCR,_______, KC_PSCR, KC_SLCK, KC_PAUS, _______, KC_END, \
        _______, RGB_RMOD,RGB_VAD, RGB_MOD, RGB_HUD, RGB_SAD, _______, QWERTY , COLEMAK, CLMK_WD, _______, _______,          _______, KC_VOLU, \
        _______, RGB_TOG, _______, _______, _______, MD_BOOT, NK_TOGG, DBG_TOG, _______, _______, _______, _______,          KC_PGUP, KC_VOLD, \
        _______, _______, _______,                            _______,                            _______, _______, KC_HOME, KC_PGDN, KC_END  \
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
        case CLMK_WD:
          if (record->event.pressed) {
            set_single_persistent_default_layer(_CLMK_WD);
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
                    rgb_matrix_disable_noeeprom();
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
